# frozen_string_literal: true

module DomniqApp
  class AppConfig < ActiveRecord::Base
    self.table_name = "#{DomniqApp.table_name_prefix}app_configs"

    validates :brand_key, presence: true
    validates :config_type, presence: true
    validates :config_key, presence: true
    validates :config_value, presence: true
    validates :config_key, uniqueness: { scope: %i[brand_key config_type] }
  end
end
