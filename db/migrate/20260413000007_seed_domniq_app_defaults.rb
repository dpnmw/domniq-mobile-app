# frozen_string_literal: true

class SeedDomniqAppDefaults < ActiveRecord::Migration[7.0]
  def up
    brand = "domniq"
    now = Time.current

    # --- Configuration: Branding ---
    branding = [
      { config_key: "app_name", config_value: "DOMNiQ" },
      { config_key: "app_tagline", config_value: "Creative HQ" },
      { config_key: "color_default_style", config_value: "Royal" },
      { config_key: "show_developer_branding", config_value: "true" },
      { config_key: "support_email", config_value: "contact@dpnmediaworks.com" },
      { config_key: "developer_name", config_value: "DPN MEDIA WORKS" },
      { config_key: "developer_slogan", config_value: "We Design, We Produce, We Network" },
      { config_key: "developer_sub_slogan", config_value: "Empowering Clients With Services That Works" },
      { config_key: "developer_website", config_value: "https://dpnmediaworks.com" },
      { config_key: "developer_email", config_value: "contact@dpnmediaworks.com" },
      { config_key: "developer_app_policy", config_value: "https://apps.dpnmediaworks.com" },
      { config_key: "developer_about", config_value: "We're a digital studio building custom web platforms, mobile apps, and media experiences. From product design and UI/UX to video production and brand strategy — we help clients ship work that lives well on every screen." },
    ]

    branding.each_with_index do |item, i|
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'branding', '#{item[:config_key]}', '#{item[:config_value].gsub("'", "''")}', #{i}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end

    # --- Configuration: Legal ---
    legal = [
      { config_key: "tos_topic_id", config_value: "7" },
      { config_key: "privacy_topic_id", config_value: "7" },
      { config_key: "faq_topic_id", config_value: "4" },
    ]

    legal.each_with_index do |item, i|
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'legal', '#{item[:config_key]}', '#{item[:config_value]}', #{i}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end

    # --- Feature Flags ---
    flags = [
      { config_key: "showPostParticipants", config_value: "false" },
      { config_key: "storyLayout", config_value: "card" },
    ]

    flags.each_with_index do |item, i|
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'feature_flags', '#{item[:config_key]}', '#{item[:config_value]}', #{i}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end

    # --- Onboarding Slides ---
    onboarding = [
      { config_key: "slide_1_title", config_value: "Connect" },
      { config_key: "slide_1_description", config_value: "Join a vibrant community blended with people who share your interests." },
      { config_key: "slide_2_title", config_value: "Discover" },
      { config_key: "slide_2_description", config_value: "Find answers, interesting discussions, and topics that matter to you." },
      { config_key: "slide_3_title", config_value: "Engage" },
      { config_key: "slide_3_description", config_value: "Participate in discussions, share your knowledge, and help others." },
    ]

    onboarding.each_with_index do |item, i|
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'onboarding', '#{item[:config_key]}', '#{item[:config_value].gsub("'", "''")}', #{i}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end

    # --- Drawer: Premium ---
    drawer_items = [
      # Premium (license-gated — requires active license to render in the app)
      { config_key: "leaderboard_stories", position: 0, config_value: '{"title":"Leaderboard Stories","description":"Top 10 This Week","icon":"Highlights","color":"#FF9500","route":"","category":"Premium","toggleKey":"storyModeTop10","featureKey":"gamification"}' },
      { config_key: "audio_bar", position: 1, config_value: '{"title":"Audio Bar","description":"Home screen audio player","icon":"AudioRooms","color":"#6C3AED","route":"","category":"Premium","comingSoon":true}' },
      { config_key: "live_events", position: 2, config_value: '{"title":"Live Events","description":"Scheduled live sessions","icon":"LiveEvents","color":"#a29bfe","route":"","category":"Premium","comingSoon":true}' },

      # Community
      { config_key: "leaderboard", position: 3, config_value: '{"title":"Leaderboard","description":"Top Contributors","icon":"Highlights","color":"#F5A623","route":"Leaderboard","category":"Community","featureKey":"gamification"}' },
      { config_key: "groups", position: 4, config_value: '{"title":"Groups","description":"Community Hub","icon":"Groups","color":"#FF6B6B","route":"Groups","category":"Community","featureKey":"groups"}' },
      { config_key: "overview", position: 5, config_value: '{"title":"Overview","description":"About this space","icon":"CommunityInfo","color":"#74b9ff","route":"AppInfo","category":"Community"}' },

      # Settings
      { config_key: "dark_mode", position: 6, config_value: '{"title":"Dark Mode","description":"Toggle dark mode","icon":"Dark","color":"#a29bfe","route":"DarkMode","category":"Settings"}' },
      { config_key: "dock_menu", position: 7, config_value: '{"title":"Dock Menu","description":"Bottom bar orientation","icon":"DockMenu","color":"#74b9ff","route":"DockMenu","category":"Settings"}' },
      { config_key: "color_style", position: 8, config_value: '{"title":"Color Style","description":"Choose a color palette","icon":"Colors","color":"#4ECDC4","route":"ColorStyle","category":"Settings"}' },
      { config_key: "icon_style", position: 9, config_value: '{"title":"Icon Style","description":"Change icon appearance","icon":"IconStyle","color":"#FF6B6B","route":"IconStyle","category":"Settings","requiresLogin":true}' },
      { config_key: "feed_style", position: 10, config_value: '{"title":"Feed Style","description":"Control feed content display","icon":"ArticleShortcut","color":"#F5A623","route":"FeedStyle","category":"Settings","requiresLogin":true}' },
      { config_key: "post_style", position: 11, config_value: '{"title":"Post Style","description":"Choose your reply experience","icon":"TopicEdit","color":"#E8590C","route":"PostStyle","category":"Settings","requiresLogin":true}' },

      # Support
      { config_key: "app_guide", position: 12, config_value: '{"title":"App Guide","description":"Learn how the app works","icon":"Highlights","color":"#4ECDC4","route":"AppGuide","category":"Support"}' },
      { config_key: "app_permissions", position: 13, config_value: '{"title":"App Permissions","description":"Camera, microphone & media","icon":"Permissions","color":"#A29BFE","route":"AppPermissions","category":"Support"}' },
      { config_key: "message_us", position: 14, config_value: '{"title":"Message Us","description":"Get in Touch","icon":"Mail","color":"#F5A623","route":"ContactUs","category":"Support"}' },

      # Admin Dashboard (staff only)
      { config_key: "admin_stats", position: 15, config_value: '{"title":"Site Stats","description":"Analytics & metrics","icon":"Admin","color":"#EF5350","route":"AdminStats","category":"Admin Dashboard","requiresStaff":true}' },
      { config_key: "admin_users", position: 16, config_value: '{"title":"Users","description":"Manage members","icon":"Groups","color":"#74b9ff","route":"AdminUsers","category":"Admin Dashboard","requiresStaff":true}' },
      { config_key: "admin_moderation", position: 17, config_value: '{"title":"Moderation","description":"Flags & review queue","icon":"SecurityShield","color":"#FF6B6B","route":"AdminReviewQueue","category":"Admin Dashboard","requiresStaff":true}' },
    ]

    drawer_items.each do |item|
      escaped_value = item[:config_value].gsub("'", "''")
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'drawer', '#{item[:config_key]}', '#{escaped_value}', #{item[:position]}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end
  end

  def down
    execute "DELETE FROM domniq_app_configs WHERE brand_key = 'domniq'"
  end
end
