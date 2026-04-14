# frozen_string_literal: true

class SeedConfigSettings < ActiveRecord::Migration[7.0]
  def up
    brand = "domniq"
    now = Time.current

    items = [
      { config_key: "deep_link_scheme", config_value: "domniq", position: 0 },
      { config_key: "default_brand", config_value: "domniq", position: 1 },
      { config_key: "use_site_branding", config_value: "false", position: 2 },
    ]

    items.each do |item|
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'branding', '#{item[:config_key]}', '#{item[:config_value]}', #{item[:position]}, true, '#{now}', '#{now}')
        ON CONFLICT (brand_key, config_type, config_key) DO NOTHING
      SQL
    end
  end

  def down
    execute "DELETE FROM domniq_app_configs WHERE config_key IN ('deep_link_scheme', 'default_brand', 'use_site_branding') AND config_type = 'branding'"
  end
end
