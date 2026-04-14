# frozen_string_literal: true

module Jobs
  class DomniqHeartbeat < ::Jobs::Scheduled
    every 1.week

    TELEMETRY_URL = "https://api.dpnmediaworks.com/telemetry/heartbeat"

    def execute(args)
      return unless SiteSetting.domniq_app_enabled
      return unless SiteSetting.domniq_app_telemetry_enabled

      payload = {
        site_url: Discourse.base_url,
        plugin_version: domniq_plugin_version,
        discourse_version: Discourse::VERSION::STRING,
        license_key: license_key,
        enabled_features: enabled_features,
        total_users: User.real.count,
        active_users_30d: User.real.where("last_seen_at > ?", 30.days.ago).count,
      }

      begin
        response = Faraday.post(TELEMETRY_URL) do |req|
          req.headers["Content-Type"] = "application/json"
          req.headers["User-Agent"] = "DomniqMobileApp/#{payload[:plugin_version]}"
          req.body = payload.to_json
          req.options.timeout = 10
          req.options.open_timeout = 5
        end

        Rails.logger.info("DomniqHeartbeat: sent (#{response.status})")
      rescue Faraday::Error => e
        Rails.logger.warn("DomniqHeartbeat: failed — #{e.message}")
      end
    end

    private

    def domniq_plugin_version
      plugin = Discourse.plugins.find { |p| p.metadata.name == "domniq-mobile-app" }
      plugin&.metadata&.version || "unknown"
    end

    def license_key
      PluginStore.get("domniq_app", "license_key") || ""
    end

    def enabled_features
      features = []
      features << "push_notifications" if SiteSetting.domniq_app_push_notifications_enabled
      features << "video_thumbnails" if SiteSetting.domniq_app_video_thumbnails_enabled
      features
    end
  end
end
