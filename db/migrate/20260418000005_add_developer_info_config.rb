# frozen_string_literal: true

class AddDeveloperInfoConfig < ActiveRecord::Migration[7.0]
  # Adds six new branding rows surfaced in the admin Configuration tab under
  # a new "Developer Info" card:
  #
  # - developer_name
  # - developer_slogan
  # - developer_sub_slogan
  # - developer_website
  # - developer_email
  # - developer_app_policy
  #
  # These drive the "App Developer · X" pill on the sidebar and AppInfo
  # screen, plus the DeveloperInfo screen hero and contact cards. Admins can
  # override these values without a rebuild. Not license-gated — same rule
  # as app_name and app_tagline (brand identity is not a premium feature).
  #
  # Safe to re-run. ON CONFLICT DO NOTHING preserves any admin-set values.
  def up
    brand = "domniq"
    now = Time.current

    new_rows = [
      { config_key: "developer_name",       config_value: "DPN MEDIA WORKS",                             position: 5 },
      { config_key: "developer_slogan",     config_value: "We Design, We Produce, We Network",           position: 6 },
      { config_key: "developer_sub_slogan", config_value: "Empowering Clients With Services That Works", position: 7 },
      { config_key: "developer_website",    config_value: "https://dpnmediaworks.com",                   position: 8 },
      { config_key: "developer_email",      config_value: "contact@dpnmediaworks.com",                   position: 9 },
      { config_key: "developer_app_policy", config_value: "https://apps.dpnmediaworks.com",               position: 10 },
    ]

    new_rows.each do |row|
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
        AND config_key IN (
          'developer_name',
          'developer_slogan',
          'developer_sub_slogan',
          'developer_website',
          'developer_email',
          'developer_app_policy'
        )
    SQL
  end
end
