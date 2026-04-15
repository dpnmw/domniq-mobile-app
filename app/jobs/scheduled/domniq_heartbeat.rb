# frozen_string_literal: true

module Jobs
  class DomniqHeartbeat < ::Jobs::Scheduled
    every 1.week

    TELEMETRY_URL = "https://api.dpnmediaworks.com/api/telemetry/heartbeat"

    def execute(args)
      return unless SiteSetting.domniq_app_enabled
      return unless SiteSetting.domniq_app_telemetry_enabled

      payload = {
        site_url: Discourse.base_url,
        plugin: "domniq-mobile-app",
        plugin_version: plugin_version,
        platform: "discourse",
        platform_version: Discourse::VERSION::STRING,
        license_key: license_key,
        licensed: DomniqApp::LicenseChecker.licensed?,
      }

      begin
        response = Excon.post(
          TELEMETRY_URL,
          body: payload.to_json,
          headers: {
            "Content-Type" => "application/json",
            "User-Agent" => "DomniqMobileApp/#{payload[:plugin_version]}",
          },
          connect_timeout: 5,
          read_timeout: 10,
        )

        Rails.logger.info("[DomniqApp] Heartbeat sent (#{response.status})")
      rescue Excon::Error => e
        Rails.logger.warn("[DomniqApp] Heartbeat failed: #{e.message}")
      end
    end

    private

    def plugin_version
      plugin = Discourse.plugins.find { |p| p.metadata.name == "domniq-mobile-app" }
      plugin&.metadata&.version || "unknown"
    end

    def license_key
      PluginStore.get("domniq_app", "license_key") || ""
    end
  end
end
