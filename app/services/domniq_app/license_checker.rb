# frozen_string_literal: true

require "ipaddr"

module DomniqApp
  class LicenseChecker
    LICENSE_CACHE_KEY = "domniq_app_license_status"
    LICENSE_CACHE_TTL = 86_400 # 24 hours
    REMOTE_URL = "https://api.dpnmediaworks.com/api/check"
    TELEMETRY_URL = "https://api.dpnmediaworks.com/api/telemetry/heartbeat"

    BLOCKED_HOSTS = %w[localhost 127.0.0.1 0.0.0.0 ::1].freeze
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
    LOCKED_DRAWER_CATEGORIES = ["Playground", "Admin Dashboard"].freeze

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
      cached = PluginStore.get("domniq_app", LICENSE_CACHE_KEY)
      if cached && cached["checked_at"] && Time.parse(cached["checked_at"]) > LICENSE_CACHE_TTL.seconds.ago
        return cached["licensed"]
      end

      result = check
      result[:licensed]
    end

    def self.license_key_masked
      key = PluginStore.get("domniq_app", "license_key")
      return nil unless key
      return key if key.length <= 8
      "#{key[0..3]}#{'*' * (key.length - 8)}#{key[-4..]}"
    end

    def self.expires_at
      cached = PluginStore.get("domniq_app", LICENSE_CACHE_KEY)
      cached&.dig("expires_at")
    end

    def self.activate(license_key)
      PluginStore.set("domniq_app", "license_key", license_key)
      check
    end

    def self.check(force: false)
      domain = current_domain
      license_key = PluginStore.get("domniq_app", "license_key")

      if blocked_domain?(domain)
        cache_result(licensed: false)
        return { success: false, licensed: false, error: "Licence validation is not available for local or private domains." }
      end

      unless license_key
        cache_result(licensed: false)
        send_heartbeat(false) if force
        return { success: false, licensed: false, error: "No licence key configured." }
      end

      begin
        response = Excon.post(
          REMOTE_URL,
          body: { license_key: license_key, domain: domain, product: "domniq-mobile-app" }.to_json,
          headers: { "Content-Type" => "application/json" },
          connect_timeout: 5,
          read_timeout: 5,
        )

        data = JSON.parse(response.body)

        if data["active"]
          result = { success: true, licensed: true, expires_at: data["expires_at"] }
          cache_result(licensed: true, expires_at: data["expires_at"])
        else
          result = { success: false, licensed: false, error: data["error"] || "Invalid licence." }
          cache_result(licensed: false)
        end

        send_heartbeat(result[:licensed]) if force
        result
      rescue Excon::Error => e
        Rails.logger.error("DomniqApp::LicenseChecker network error: #{e.message}")
        cached = PluginStore.get("domniq_app", LICENSE_CACHE_KEY)
        if cached
          { success: true, licensed: cached["licensed"] }
        else
          { success: false, licensed: false, error: "Unable to verify licence." }
        end
      rescue => e
        Rails.logger.error("DomniqApp::LicenseChecker: #{e.message}")
        { success: false, licensed: false, error: "Unable to verify licence." }
      end
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

    def self.cache_result(licensed:, expires_at: nil)
      PluginStore.set("domniq_app", LICENSE_CACHE_KEY, {
        "licensed" => licensed,
        "expires_at" => expires_at,
        "checked_at" => Time.current.iso8601,
      })
    end

    def self.send_heartbeat(is_licensed)
      return unless SiteSetting.respond_to?(:domniq_app_telemetry_enabled) && SiteSetting.domniq_app_telemetry_enabled

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
              license_key: PluginStore.get("domniq_app", "license_key"),
              licensed: is_licensed,
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
  end
end
