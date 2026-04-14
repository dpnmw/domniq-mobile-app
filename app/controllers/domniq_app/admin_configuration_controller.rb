# frozen_string_literal: true

module DomniqApp
  class AdminConfigurationController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def index
      brand_key = params[:brand] || "domniq"
      configs = AppConfig.where(brand_key: brand_key)

      if params[:config_type].present?
        configs = configs.where(config_type: params[:config_type])
      end

      render json: {
        configs: configs.order(:config_type, :position).map { |c|
          {
            id: c.id,
            brand_key: c.brand_key,
            config_type: c.config_type,
            config_key: c.config_key,
            config_value: c.config_value,
            position: c.position,
            enabled: c.enabled,
          }
        },
      }
    end

    def create
      config = AppConfig.create!(config_params)
      bump_config_version(config.brand_key)

      render json: { config: serialize_config(config) }
    end

    def update
      config = AppConfig.find(params[:id])
      config.update!(config_params)
      bump_config_version(config.brand_key)

      render json: { config: serialize_config(config) }
    end

    def bulk_update
      brand_key = params[:brand] || "domniq"

      if params[:configs].present?
        params[:configs].each do |cfg|
          record = AppConfig.find_by(id: cfg[:id])
          next unless record
          record.update!(config_value: cfg[:config_value])
        end
      end

      bump_config_version(brand_key)
      render json: success_json
    end

    def destroy
      config = AppConfig.find(params[:id])
      brand_key = config.brand_key
      config.destroy!
      bump_config_version(brand_key)

      render json: success_json
    end

    private

    def config_params
      params.require(:config).permit(:brand_key, :config_type, :config_key, :config_value, :position, :enabled)
    end

    def serialize_config(config)
      {
        id: config.id,
        brand_key: config.brand_key,
        config_type: config.config_type,
        config_key: config.config_key,
        config_value: config.config_value,
        position: config.position,
        enabled: config.enabled,
      }
    end

    def bump_config_version(brand_key)
      current = PluginStore.get("domniq_app", "config_version:#{brand_key}") || 0
      PluginStore.set("domniq_app", "config_version:#{brand_key}", current + 1)
    end

  end
end
