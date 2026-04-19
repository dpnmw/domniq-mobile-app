# frozen_string_literal: true

require "ipaddr"

module DomniqApp
  class LicenseChecker
    CACHE_KEY = "dma_license_status"
    CACHE_TTL = 86_400 # 24 hours
    REMOTE_URL = "https://api.dpnmediaworks.com/api/check"
    TELEMETRY_URL = "https://api.dpnmediaworks.com/api/telemetry/heartbeat"

    BLOCKED_HOSTS = %w[
      localhost
      127.0.0.1
      0.0.0.0
      ::1
    ].freeze

    PRIVATE_RANGES = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
    ].freeze

    # Locked config types — fully locked sections
    LOCKED_SECTION_TYPES = %w[onboarding].freeze

    # Locked config keys per config_type — partial locks
    LOCKED_CONFIG_KEYS = {
      "branding" => %w[use_site_branding show_developer_branding],
      "feature_flags" => :all, # All feature flags are locked
    }.freeze

    # Locked drawer categories
    # "Playground" is the legacy category name retained so mid-migration servers
    # (before 20260418000004 runs) still have the correct gating. Once every
    # server is past that migration it can be dropped.
    LOCKED_DRAWER_CATEGORIES = ["Premium", "Playground", "Admin Dashboard"].freeze

    # Locked site settings
    LOCKED_SITE_SETTINGS = %w[domniq_app_video_thumbnails_enabled].freeze

    # Notifications endpoints locked (registered devices stats + find user devices)
    NOTIFICATIONS_LOCKED = true

    def self.section_fully_locked?(config_type)
      return false if licensed?
      LOCKED_SECTION_TYPES.include?(config_type.to_s)
    end

    def self.config_locked?(config_type, config_key = nil)
      return false if licensed?
      return true if LOCKED_SECTION_TYPES.include?(config_type.to_s)
      return false unless LOCKED_CONFIG_KEYS.key?(config_type.to_s)
      locked = LOCKED_CONFIG_KEYS[config_type.to_s]
      return true if locked == :all
      return true if config_key.nil?
      locked.include?(config_key.to_s)
    end

    def self.drawer_category_locked?(category)
      return false if licensed?
      LOCKED_DRAWER_CATEGORIES.include?(category.to_s)
    end

    def self.site_setting_locked?(key)
      return false if licensed?
      LOCKED_SITE_SETTINGS.include?(key.to_s)
    end

    def self.notifications_locked?
      return false if licensed?
      NOTIFICATIONS_LOCKED
    end

    def self.licensed?
      result = check
      result && result["license_active"] == true
    end

    def self.check(force: false)
      domain = current_domain

      return blocked_result(domain) if blocked_domain?(domain)

      unless force
        cached = read_cache
        if cached && !cache_expired?(cached)
          return cached
        end
      end

      key = license_key
      if key.blank?
        result = {
          "license_active" => false,
          "domain" => domain,
          "error" => "No license key configured",
          "checked_at" => Time.now.iso8601,
        }
        store_result(result)
        send_heartbeat(result) if force && SiteSetting.respond_to?(:domniq_app_telemetry_enabled) && SiteSetting.domniq_app_telemetry_enabled
        return result
      end

      result = remote_check(domain, key)
      store_result(result)
      send_heartbeat(result) if force && SiteSetting.respond_to?(:domniq_app_telemetry_enabled) && SiteSetting.domniq_app_telemetry_enabled
      result
    end

    def self.license_key
      PluginStore.get("domniq_app", "license_key")
    end

    def self.activate(key)
      PluginStore.set("domniq_app", "license_key", key)
      check(force: true)
    end

    def self.license_key_masked
      key = license_key
      return nil if key.blank?
      return key if key.length <= 8
      key[0..3] + ("*" * (key.length - 8)) + key[-4..]
    end

    def self.expires_at
      cached = read_cache
      cached&.dig("expires_at")
    end

    def self.tier
      cached = read_cache
      cached&.dig("tier")
    end

    def self.current_domain
      URI.parse(Discourse.base_url).host
    rescue StandardError
      "unknown"
    end

    private

    def self.blocked_domain?(domain)
      return true if BLOCKED_HOSTS.include?(domain.downcase)
      begin
        ip = IPAddr.new(domain)
        PRIVATE_RANGES.any? { |range| range.include?(ip) }
      rescue IPAddr::InvalidAddressError
        false
      end
    end

    def self.blocked_result(domain)
      {
        "license_active" => false,
        "domain" => domain,
        "error" => "License validation is not available for local or private domains",
        "checked_at" => Time.now.iso8601,
      }
    end

    def self.remote_check(domain, key)
      response = Excon.post(
        REMOTE_URL,
        body: { license_key: key, domain: domain, product: "domniq-mobile-app" }.to_json,
        headers: { "Content-Type" => "application/json" },
        connect_timeout: 5,
        read_timeout: 5,
      )

      data = JSON.parse(response.body)
      {
        "license_active" => data["active"] == true,
        "domain" => domain,
        "email" => data["email"],
        "paid_at" => data["paid_at"],
        "expires_at" => data["expires_at"],
        "tier" => data["tier"],
        "error" => data["error"],
        "checked_at" => Time.now.iso8601,
      }
    rescue Excon::Error => e
      Rails.logger.warn("[DomniqApp] License check network error: #{e.message}")
      fallback_result(domain)
    rescue JSON::ParserError, StandardError => e
      Rails.logger.warn("[DomniqApp] License check failed: #{e.message}")
      inactive_result(domain, "Unable to verify licence")
    end

    def self.inactive_result(domain, error = nil)
      {
        "license_active" => false,
        "domain" => domain,
        "error" => error,
        "checked_at" => Time.now.iso8601,
      }
    end

    def self.fallback_result(domain)
      cached = read_cache
      if cached && cached["license_active"]
        cached["domain"] = domain
        cached
      else
        {
          "license_active" => false,
          "domain" => domain,
          "checked_at" => Time.now.iso8601,
        }
      end
    end

    def self.read_cache
      PluginStore.get("domniq_app", CACHE_KEY)
    end

    def self.store_result(result)
      PluginStore.set("domniq_app", CACHE_KEY, result)
    end

    def self.send_heartbeat(result)
      Thread.new do
        begin
          plugin = Discourse.plugins.find { |p| p.metadata.name == "domniq-mobile-app" }
          Excon.post(
            TELEMETRY_URL,
            body: {
              site_url: Discourse.base_url,
              plugin: "domniq-mobile-app",
              plugin_version: plugin&.metadata&.version || "unknown",
              platform: "discourse",
              platform_version: Discourse::VERSION::STRING,
              license_key: license_key,
              licensed: result["license_active"] == true,
            }.to_json,
            headers: { "Content-Type" => "application/json" },
            connect_timeout: 5,
            read_timeout: 5,
          )
        rescue StandardError => e
          Rails.logger.warn("[DomniqApp] Heartbeat failed: #{e.message}")
        end
      end
    end

    def self.cache_expired?(cached)
      checked_at = cached["checked_at"]
      return true unless checked_at
      Time.parse(checked_at) < Time.now - CACHE_TTL
    rescue StandardError
      true
    end
  end
end
