# frozen_string_literal: true

class RenameDeveloperFacebookToAppPolicy < ActiveRecord::Migration[7.0]
  # Renames the `developer_facebook` branding row to `developer_app_policy`.
  # Live servers already have a `developer_facebook` row from an earlier
  # migration — we keep position 10 but repoint the key and reset the value to
  # the new App Policy default. Admins who had already edited the Facebook URL
  # will lose it, which is intentional: the field's meaning has changed, and
  # a stale Facebook URL under a new label would be worse than reseeding.
  #
  # Idempotent and safe to re-run: the UPDATE is a no-op after the first pass,
  # and the INSERT fallback only fires on forums where the original row never
  # existed (e.g. someone who installed the plugin after this migration).
  def up
    brand = "domniq"
    now = Time.current
    default_url = "https://apps.dpnmediaworks.com"

    # Rename any existing facebook row in place (preserves position, created_at).
    execute <<~SQL
      UPDATE domniq_app_configs
      SET config_key = 'developer_app_policy',
          config_value = '#{default_url}',
          updated_at = '#{now}'
      WHERE brand_key = '#{brand}'
        AND config_type = 'branding'
        AND config_key = 'developer_facebook'
    SQL

    # If neither row exists (rare — fresh install without prior seed), create it
    # so the Developer Info card always has an App Policy field.
    execute <<~SQL
      INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
      VALUES ('#{brand}', 'branding', 'developer_app_policy', '#{default_url}', 10, true, '#{now}', '#{now}')
      ON CONFLICT DO NOTHING
    SQL
  end

  def down
    # Reverse: rename back to developer_facebook with the legacy default.
    execute <<~SQL
      UPDATE domniq_app_configs
      SET config_key = 'developer_facebook',
          config_value = 'https://fb.com/dpnmediaworks'
      WHERE brand_key = 'domniq'
        AND config_type = 'branding'
        AND config_key = 'developer_app_policy'
    SQL
  end
end
