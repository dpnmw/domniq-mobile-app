# frozen_string_literal: true

class CleanupStaleDomniqConfigs < ActiveRecord::Migration[7.0]
  def up
    # Remove color_primary, color_secondary, color_tertiary, app_scheme
    # and developer_* entries that were seeded in earlier versions
    execute <<~SQL
      DELETE FROM domniq_app_configs
      WHERE config_key IN (
        'color_primary', 'color_secondary', 'color_tertiary',
        'app_scheme',
        'developer_name', 'developer_slogan', 'developer_sub_slogan',
        'developer_website', 'developer_email', 'developer_facebook'
      )
    SQL
  end

  def down
    # No-op — these were stale data
  end
end
