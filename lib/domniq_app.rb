# frozen_string_literal: true

module ::DomniqApp
  PLUGIN_NAME = "domniq-mobile-app"

  def self.table_name_prefix
    "domniq_app_"
  end

  def self.enabled?
    SiteSetting.domniq_app_enabled
  end
end

require_relative "domniq_app/engine"
