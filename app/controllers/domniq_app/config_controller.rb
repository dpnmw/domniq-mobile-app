# frozen_string_literal: true

module DomniqApp
  class ConfigController < ::ApplicationController
    requires_plugin ::DomniqApp::PLUGIN_NAME


    def show
      brand_key = params[:brand] || "domniq"

      config = DomniqApp::ConfigBuilder.build(brand_key)
      version = PluginStore.get("domniq_app", "config_version:#{brand_key}") || 0
      etag = "\"#{brand_key}-v#{version}\""

      if stale?(etag: etag, public: true)
        response.headers["Cache-Control"] = "public, max-age=300"
        render json: config
      end
    end
  end
end
