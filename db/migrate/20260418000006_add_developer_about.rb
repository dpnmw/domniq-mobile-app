# frozen_string_literal: true

class AddDeveloperAbout < ActiveRecord::Migration[7.0]
  # Adds the `developer_about` branding row — the paragraph shown on the
  # DeveloperInfo screen under the "ABOUT" section. Drives admin control of
  # that paragraph from the plugin Developer Info card (rendered as a
  # textarea in the admin UI so multi-line editing works cleanly).
  #
  # Safe to re-run. ON CONFLICT DO NOTHING preserves any admin-set value.
  def up
    brand = "domniq"
    now = Time.current
    default_about = "We're a digital studio building custom web platforms, mobile apps, and media experiences. From product design and UI/UX to video production and brand strategy — we help clients ship work that lives well on every screen."
    escaped = default_about.gsub("'", "''")

    execute <<~SQL
      INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
      VALUES ('#{brand}', 'branding', 'developer_about', '#{escaped}', 11, true, '#{now}', '#{now}')
      ON CONFLICT DO NOTHING
    SQL
  end

  def down
    execute <<~SQL
      DELETE FROM domniq_app_configs
      WHERE brand_key = 'domniq'
        AND config_type = 'branding'
        AND config_key = 'developer_about'
    SQL
  end
end
