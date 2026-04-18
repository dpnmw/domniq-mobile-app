# frozen_string_literal: true

class UpdateDrawerPermissionsAndSupport < ActiveRecord::Migration[7.0]
  # Mirrors the mobile app's sidebar changes on 2026-04-18:
  # - Removes the in-app Push Notifications preferences screen entry.
  # - Removes the standalone App Developer entry (developer credit moved to
  #   the sidebar hero pill and AppInfo screen).
  # - Moves App Permissions from the Settings card into the Support card,
  #   renamed from "Device Permissions" to "App Permissions" for consistency.
  def up
    # Drop entries that were retired in the sidebar redesign.
    execute <<~SQL
      DELETE FROM domniq_app_configs
      WHERE config_key IN ('push_notifications_prefs', 'app_developer', 'device_permissions')
    SQL

    # Reinsert permissions under the Support card with the renamed title.
    # ON CONFLICT uses the unique (brand_key, config_type, config_key) index.
    execute <<~SQL
      INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
      VALUES (
        'domniq',
        'drawer',
        'app_permissions',
        '{"title":"App Permissions","description":"Camera, microphone & media","icon":"Permissions","color":"#A29BFE","route":"AppPermissions","category":"Support"}',
        14,
        true,
        NOW(),
        NOW()
      )
      ON CONFLICT (brand_key, config_type, config_key) DO UPDATE
      SET config_value = EXCLUDED.config_value,
          position = EXCLUDED.position,
          updated_at = NOW()
    SQL
  end

  def down
    # No-op — the previous state is reconstructible from earlier migrations.
  end
end
