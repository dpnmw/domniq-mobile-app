# frozen_string_literal: true

class SeedOnboardingSlides < ActiveRecord::Migration[7.0]
  def up
    brand = "domniq"
    now = Time.current

    slides = [
      { config_key: "slide_1_title", config_value: "Connect", position: 0 },
      { config_key: "slide_1_description", config_value: "Join a vibrant community blended with people who share your interests.", position: 1 },
      { config_key: "slide_2_title", config_value: "Discover", position: 2 },
      { config_key: "slide_2_description", config_value: "Find answers, interesting discussions, and topics that matter to you.", position: 3 },
      { config_key: "slide_3_title", config_value: "Engage", position: 4 },
      { config_key: "slide_3_description", config_value: "Participate in discussions, share your knowledge, and help others.", position: 5 },
    ]

    slides.each do |item|
      escaped = item[:config_value].gsub("'", "''")
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'onboarding', '#{item[:config_key]}', '#{escaped}', #{item[:position]}, true, '#{now}', '#{now}')
        ON CONFLICT (brand_key, config_type, config_key) DO NOTHING
      SQL
    end
  end

  def down
    execute "DELETE FROM domniq_app_configs WHERE config_type = 'onboarding' AND brand_key = 'domniq'"
  end
end
