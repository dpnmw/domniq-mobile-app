# frozen_string_literal: true

module DomniqApp
  class LicenseChecker
    LICENSE_CACHE_KEY = "domniq_app_license_status"
    LICENSE_CACHE_TTL = 24.hours

    def self.licensed?
      cached = PluginStore.get("domniq_app", LICENSE_CACHE_KEY)
      return cached["licensed"] if cached && Time.parse(cached["checked_at"]) > LICENSE_CACHE_TTL.ago

      result = check
      result[:licensed]
    end

    def self.license_key_masked
      key = PluginStore.get("domniq_app", "license_key")
      return nil unless key

      "#{key[0..3]}#{'*' * (key.length - 8)}#{key[-4..]}"
    end

    def self.expires_at
      cached = PluginStore.get("domniq_app", LICENSE_CACHE_KEY)
      cached&.dig("expires_at")
    end

    def self.activate(license_key)
      # Store the license key
      PluginStore.set("domniq_app", "license_key", license_key)

      # Validate against the DPN Media Works API
      check
    end

    def self.check
      license_key = PluginStore.get("domniq_app", "license_key")

      unless license_key
        cache_result(licensed: false)
        return { success: false, licensed: false, error: "No license key configured." }
      end

      begin
        # Call DPN Media Works licensing API
        response = Excon.post(
          "https://api.dpnmediaworks.com/licenses/verify",
          body: { license_key: license_key, domain: Discourse.base_url }.to_json,
          headers: { "Content-Type" => "application/json" },
          connect_timeout: 10,
          read_timeout: 10,
        )

        data = JSON.parse(response.body)

        if data["valid"]
          cache_result(licensed: true, expires_at: data["expires_at"])
          { success: true, licensed: true, expires_at: data["expires_at"] }
        else
          cache_result(licensed: false)
          { success: false, licensed: false, error: data["error"] || "Invalid license." }
        end
      rescue => e
        Rails.logger.error("DomniqApp::LicenseChecker: #{e.message}")
        # On network failure, use cached result if available
        cached = PluginStore.get("domniq_app", LICENSE_CACHE_KEY)
        if cached
          { success: true, licensed: cached["licensed"] }
        else
          { success: false, licensed: false, error: "Unable to verify license." }
        end
      end
    end

    private

    def self.cache_result(licensed:, expires_at: nil)
      PluginStore.set("domniq_app", LICENSE_CACHE_KEY, {
        "licensed" => licensed,
        "expires_at" => expires_at,
        "checked_at" => Time.current.iso8601,
      })
    end
  end
end
