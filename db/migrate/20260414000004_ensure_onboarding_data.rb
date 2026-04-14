# frozen_string_literal: true

class EnsureOnboardingData < ActiveRecord::Migration[7.0]
  def up
    brand = "domniq"
    now = Time.current

    slides = [
      ["slide_1_title", "Connect", 0],
      ["slide_1_description", "Join a vibrant community blended with people who share your interests.", 1],
      ["slide_2_title", "Discover", 2],
      ["slide_2_description", "Find answers, interesting discussions, and topics that matter to you.", 3],
      ["slide_3_title", "Engage", 4],
      ["slide_3_description", "Participate in discussions, share your knowledge, and help others.", 5],
    ]

    slides.each do |key, value, pos|
      # Check if it already exists
      result = execute("SELECT id FROM domniq_app_configs WHERE brand_key = '#{brand}' AND config_type = 'onboarding' AND config_key = '#{key}' LIMIT 1")
      if result.ntuples == 0
        escaped = value.gsub("'", "''")
        execute <<~SQL
          INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
          VALUES ('#{brand}', 'onboarding', '#{key}', '#{escaped}', #{pos}, true, '#{now}', '#{now}')
        SQL
      end
    end

    # Also ensure use_site_branding, deep_link_scheme, default_brand exist
    settings = [
      ["use_site_branding", "false", 10],
      ["deep_link_scheme", "domniq", 11],
    ]

    settings.each do |key, value, pos|
      result = execute("SELECT id FROM domniq_app_configs WHERE brand_key = '#{brand}' AND config_type = 'branding' AND config_key = '#{key}' LIMIT 1")
      if result.ntuples == 0
        execute <<~SQL
          INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
          VALUES ('#{brand}', 'branding', '#{key}', '#{value}', #{pos}, true, '#{now}', '#{now}')
        SQL
      end
    end
  end

  def down
    # No-op
  end
end
