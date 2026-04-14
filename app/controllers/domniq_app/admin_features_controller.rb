# frozen_string_literal: true

module DomniqApp
  class AdminFeaturesController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    before_action :ensure_licensed!, only: %i[update]

    def index
      brand_key = params[:brand] || SiteSetting.domniq_app_default_brand
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
      brand_key = params[:brand] || SiteSetting.domniq_app_default_brand

      if params[:flags].present?
        params[:flags].each do |flag|
          record = AppConfig.find_or_initialize_by(
            brand_key: brand_key,
            config_type: "feature_flags",
            config_key: flag[:config_key],
          )
          record.update!(config_value: flag[:config_value], enabled: flag.fetch(:enabled, true))
        end
      end

      if params.key?(:video_thumbnails_enabled)
        SiteSetting.domniq_app_video_thumbnails_enabled = params[:video_thumbnails_enabled]
      end

      bump_config_version(brand_key)

      render json: success_json
    end

    private

    def bump_config_version(brand_key)
      current = PluginStore.get("domniq_app", "config_version:#{brand_key}") || 0
      PluginStore.set("domniq_app", "config_version:#{brand_key}", current + 1)
    end

    def ensure_licensed!
      unless DomniqApp::LicenseChecker.licensed?
        raise Discourse::InvalidAccess.new(I18n.t("domniq_app.errors.not_licensed"))
      end
    end
  end
end
