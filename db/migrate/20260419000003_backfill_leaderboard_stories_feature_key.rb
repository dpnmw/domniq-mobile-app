# frozen_string_literal: true

class BackfillLeaderboardStoriesFeatureKey < ActiveRecord::Migration[7.0]
  # Adds `"featureKey":"gamification"` to the `leaderboard_stories` drawer
  # item's config_value JSON on live forums. Earlier seed migrations omitted
  # this key, which meant the mobile app couldn't gate the item on whether
  # the Gamification plugin was actually enabled on the forum — admins saw
  # it appearing "enabled" even when Gamification was off.
  #
  # Surgical string REPLACE on the stored JSON: inject the key before the
  # closing brace. Idempotent — the WHERE filter skips rows that already
  # contain `featureKey`, so re-running is a no-op.
  def up
    execute <<~SQL
      UPDATE domniq_app_configs
      SET config_value = REPLACE(
            config_value,
            '"toggleKey":"storyModeTop10"}',
            '"toggleKey":"storyModeTop10","featureKey":"gamification"}'
          ),
          updated_at = NOW()
      WHERE config_type = 'drawer'
        AND config_key = 'leaderboard_stories'
        AND config_value NOT LIKE '%"featureKey"%'
        AND config_value LIKE '%"toggleKey":"storyModeTop10"}%'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE domniq_app_configs
      SET config_value = REPLACE(
            config_value,
            '"toggleKey":"storyModeTop10","featureKey":"gamification"}',
            '"toggleKey":"storyModeTop10"}'
          ),
          updated_at = NOW()
      WHERE config_type = 'drawer'
        AND config_key = 'leaderboard_stories'
        AND config_value LIKE '%"toggleKey":"storyModeTop10","featureKey":"gamification"}%'
    SQL
  end
end
