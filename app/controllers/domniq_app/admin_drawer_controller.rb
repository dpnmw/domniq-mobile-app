# frozen_string_literal: true

module DomniqApp
  class AdminDrawerController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def index
      brand_key = params[:brand] || "domniq"
      items = AppConfig.where(brand_key: brand_key, config_type: "drawer").order(:position)

      render json: {
        items: items.map { |c| serialize_config(c) },
      }
    end

    def create
      config = AppConfig.create!(drawer_params.merge(config_type: "drawer"))
      bump_config_version(config.brand_key)

      render json: { item: serialize_config(config) }
    end

    def update
      config = AppConfig.find(params[:id])
      if drawer_item_locked?(config)
        return render json: { error: "Requires a valid licence" }, status: :forbidden
      end
      config.update!(drawer_params)
      bump_config_version(config.brand_key)

      render json: { item: serialize_config(config) }
    end

    def destroy
      config = AppConfig.find(params[:id])
      brand_key = config.brand_key
      config.destroy!
      bump_config_version(brand_key)

      render json: success_json
    end

    def reorder
      params.require(:order).each do |item|
        AppConfig.where(id: item[:id]).update_all(position: item[:position])
      end

      brand_key = params[:brand] || "domniq"
      bump_config_version(brand_key)

      render json: success_json
    end

    private

    def drawer_item_locked?(config)
      return false unless defined?(DomniqApp::LicenseChecker)
      category = begin
        JSON.parse(config.config_value.to_s)["category"]
      rescue StandardError
        nil
      end
      return false unless category
      DomniqApp::LicenseChecker.drawer_category_locked?(category)
    end

    def drawer_params
      params.require(:item).permit(:brand_key, :config_key, :config_value, :position, :enabled)
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
