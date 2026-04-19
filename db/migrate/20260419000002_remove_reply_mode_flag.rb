# frozen_string_literal: true

class RemoveReplyModeFlag < ActiveRecord::Migration[7.0]
  # Drops the `replyMode` feature flag. Reply style was miscategorized as a
  # feature flag — it's actually a user preference (each user picks their own
  # reply experience via the Post Style screen in the mobile app, backed by
  # AsyncStorage). The flag was never read by the app and only cluttered the
  # admin Features tab.
  #
  # Safe to re-run: DELETE is idempotent. No data loss concern — the value
  # wasn't wired to any app behavior.
  def up
    execute <<~SQL
      DELETE FROM domniq_app_configs
      WHERE brand_key = 'domniq'
        AND config_type = 'feature_flags'
        AND config_key = 'replyMode'
    SQL
  end

  def down
    now = Time.current
    execute <<~SQL
      INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
      VALUES ('domniq', 'feature_flags', 'replyMode', 'sheet', 2, true, '#{now}', '#{now}')
      ON CONFLICT DO NOTHING
    SQL
  end
end
