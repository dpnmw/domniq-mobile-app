# frozen_string_literal: true

class AddSupportAndDeveloperBrandingConfig < ActiveRecord::Migration[7.0]
  # Adds two new branding configuration fields surfaced in the admin
  # Configuration tab:
  #
  # - support_email: the contact email shown in the ContactUs screen.
  # - show_developer_branding: toggle for the "App Developer" pills on the
  #   sidebar hero and AppInfo screen.
  #
  # Safe to re-run. ON CONFLICT DO NOTHING preserves any admin-set values.
  def up
    brand = "domniq"
    now = Time.current

    new_branding_rows = [
      { config_key: "show_developer_branding", config_value: "true", position: 3 },
      { config_key: "support_email",           config_value: "contact@dpnmediaworks.com", position: 4 },
    ]

    new_branding_rows.each do |row|
      escaped_value = row[:config_value].gsub("'", "''")
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'branding', '#{row[:config_key]}', '#{escaped_value}', #{row[:position]}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end
  end

  def down
    execute <<~SQL
      DELETE FROM domniq_app_configs
      WHERE brand_key = 'domniq'
        AND config_type = 'branding'
        AND config_key IN ('show_developer_branding', 'support_email')
    SQL
  end
end
