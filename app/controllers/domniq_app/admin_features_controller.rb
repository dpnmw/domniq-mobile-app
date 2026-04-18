# frozen_string_literal: true

module DomniqApp
  class AdminFeaturesController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def index
      brand_key = params[:brand] || "domniq"
      flags = AppConfig.where(brand_key: brand_key, config_type: "feature_flags").order(:config_key)

      render json: {
        flags: flags.map { |f|
          {
            id: f.id,
            brand_key: f.brand_key,
            config_key: f.config_key,
            config_value: f.config_value,
            enabled: f.enabled,
          }
        },
        video_thumbnails_enabled: SiteSetting.domniq_app_video_thumbnails_enabled,
      }
    end

    def update
      brand_key = params[:brand] || "domniq"
      licensed = !(defined?(DomniqApp::LicenseChecker) && !DomniqApp::LicenseChecker.licensed?)

      if params[:flags].present?
        flags_data = params[:flags]
        flags_data = flags_data.values if flags_data.is_a?(ActionController::Parameters)

        flags_data.each do |flag|
          flag = flag.to_unsafe_h if flag.respond_to?(:to_unsafe_h)
          # Silently skip all feature flags if locked
          next if defined?(DomniqApp::LicenseChecker) &&
                  DomniqApp::LicenseChecker.config_locked?("feature_flags", flag["config_key"])
          record = AppConfig.find_or_initialize_by(
            brand_key: brand_key,
            config_type: "feature_flags",
            config_key: flag["config_key"],
          )
          enabled = flag.key?("enabled") ? flag["enabled"] : true
          record.update!(config_value: flag["config_value"], enabled: enabled)
        end
      end

      if params.key?(:video_thumbnails_enabled)
        # Silently skip if locked
        unless defined?(DomniqApp::LicenseChecker) &&
               DomniqApp::LicenseChecker.site_setting_locked?("domniq_app_video_thumbnails_enabled")
          SiteSetting.domniq_app_video_thumbnails_enabled =
            ActiveModel::Type::Boolean.new.cast(params[:video_thumbnails_enabled])
        end
      end

      bump_config_version(brand_key)

      render json: success_json
    end

    private

    def bump_config_version(brand_key)
      current = PluginStore.get("domniq_app", "config_version:#{brand_key}") || 0
      PluginStore.set("domniq_app", "config_version:#{brand_key}", current + 1)
    end

  end
end
