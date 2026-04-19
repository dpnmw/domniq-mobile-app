# frozen_string_literal: true

class AddAudioBarToPlayground < ActiveRecord::Migration[7.0]
  # Brings live servers up to the current seed file state:
  #
  # 1. Inserts missing rows (e.g. admin_* entries on servers seeded before
  #    2026-04-14, plus audio_bar as the new Coming Soon Premium item).
  # 2. Renumbers all drawer positions sequentially so the ordering is clean
  #    across all five categories.
  #
  # Note on category name: the Premium card was renamed from "Playground" in
  # a follow-up migration (20260418000004). This file's canonical rows use
  # the new "Premium" name so fresh installs skip the rename round-trip.
  # Already-migrated servers are corrected by 20260418000004.
  #
  # Safe to re-run: uses INSERT ... ON CONFLICT and UPDATE-by-key.
  def up
    brand = "domniq"
    now = Time.current

    # Canonical target state — order is the display order, position is the index.
    drawer_items = [
      # Premium
      { config_key: "leaderboard_stories", config_value: '{"title":"Leaderboard Stories","description":"Top 10 This Week","icon":"Highlights","color":"#FF9500","route":"","category":"Premium","toggleKey":"storyModeTop10"}' },
      { config_key: "audio_bar",            config_value: '{"title":"Audio Bar","description":"Home screen audio player","icon":"AudioRooms","color":"#6C3AED","route":"","category":"Premium","comingSoon":true}' },
      { config_key: "live_events",          config_value: '{"title":"Live Events","description":"Scheduled live sessions","icon":"LiveEvents","color":"#a29bfe","route":"","category":"Premium","comingSoon":true}' },

      # Community
      { config_key: "leaderboard",          config_value: '{"title":"Leaderboard","description":"Top Contributors","icon":"Highlights","color":"#F5A623","route":"Leaderboard","category":"Community","featureKey":"gamification"}' },
      { config_key: "groups",               config_value: '{"title":"Groups","description":"Community Hub","icon":"Groups","color":"#FF6B6B","route":"Groups","category":"Community","featureKey":"groups"}' },
      { config_key: "overview",             config_value: '{"title":"Overview","description":"About this space","icon":"CommunityInfo","color":"#74b9ff","route":"AppInfo","category":"Community"}' },

      # Settings
      { config_key: "dark_mode",            config_value: '{"title":"Dark Mode","description":"Toggle dark mode","icon":"Dark","color":"#a29bfe","route":"DarkMode","category":"Settings"}' },
      { config_key: "dock_menu",            config_value: '{"title":"Dock Menu","description":"Bottom bar orientation","icon":"DockMenu","color":"#74b9ff","route":"DockMenu","category":"Settings"}' },
      { config_key: "color_style",          config_value: '{"title":"Color Style","description":"Choose a color palette","icon":"Colors","color":"#4ECDC4","route":"ColorStyle","category":"Settings"}' },
      { config_key: "icon_style",           config_value: '{"title":"Icon Style","description":"Change icon appearance","icon":"IconStyle","color":"#FF6B6B","route":"IconStyle","category":"Settings","requiresLogin":true}' },
      { config_key: "feed_style",           config_value: '{"title":"Feed Style","description":"Control feed content display","icon":"ArticleShortcut","color":"#F5A623","route":"FeedStyle","category":"Settings","requiresLogin":true}' },
      { config_key: "post_style",           config_value: '{"title":"Post Style","description":"Choose your reply experience","icon":"TopicEdit","color":"#E8590C","route":"PostStyle","category":"Settings","requiresLogin":true}' },

      # Support
      { config_key: "app_guide",            config_value: '{"title":"App Guide","description":"Learn how the app works","icon":"Highlights","color":"#4ECDC4","route":"AppGuide","category":"Support"}' },
      { config_key: "app_permissions",      config_value: '{"title":"App Permissions","description":"Camera, microphone & media","icon":"Permissions","color":"#A29BFE","route":"AppPermissions","category":"Support"}' },
      { config_key: "message_us",           config_value: '{"title":"Message Us","description":"Get in Touch","icon":"Mail","color":"#F5A623","route":"ContactUs","category":"Support"}' },

      # Admin Dashboard (staff only)
      { config_key: "admin_stats",          config_value: '{"title":"Site Stats","description":"Analytics & metrics","icon":"Admin","color":"#EF5350","route":"AdminStats","category":"Admin Dashboard","requiresStaff":true}' },
      { config_key: "admin_users",          config_value: '{"title":"Users","description":"Manage members","icon":"Groups","color":"#74b9ff","route":"AdminUsers","category":"Admin Dashboard","requiresStaff":true}' },
      { config_key: "admin_moderation",     config_value: '{"title":"Moderation","description":"Flags & review queue","icon":"SecurityShield","color":"#FF6B6B","route":"AdminReviewQueue","category":"Admin Dashboard","requiresStaff":true}' },
    ]

    drawer_items.each_with_index do |item, position|
      escaped_value = item[:config_value].gsub("'", "''")
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'drawer', '#{item[:config_key]}', '#{escaped_value}', #{position}, true, '#{now}', '#{now}')
        ON CONFLICT (brand_key, config_type, config_key) DO UPDATE
        SET config_value = EXCLUDED.config_value,
            position = EXCLUDED.position,
            updated_at = NOW()
      SQL
    end
  end

  def down
    # No-op — the previous state is reconstructible from the original seed
    # migration plus the permissions/support update migration.
  end
end
