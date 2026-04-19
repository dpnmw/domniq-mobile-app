# frozen_string_literal: true

class AddWidgetsDrawerCategory < ActiveRecord::Migration[7.0]
  # Adds four home-screen widget tiles as a new `Widgets` drawer category.
  # Shown above Premium in the plugin admin drawer editor; license-gated like
  # Premium and Admin Dashboard (config_builder drops the whole category from
  # the mobile app's /domniq-app/config response when the forum is unlicensed).
  #
  # Admin toggles are deliberately absent on this category — widgets are a
  # premium package, not individually managed. License is the only gate.
  #
  # Positions -4 to -1 keep widgets ordered first in the response without
  # renumbering the existing drawer rows (positions 0+).
  #
  # Icon + color values mirror TRENDING_TABS in frontend/custom/screens/
  # SidebarDefault.tsx so the plugin admin UI renders the same visuals as the
  # app's home sidebar.
  #
  # Safe to re-run: ON CONFLICT preserves any admin-edited value.
  def up
    brand = "domniq"
    now = Time.current

    widgets = [
      { config_key: "widget_activity", position: -4, config_value: '{"title":"Activity","description":"Recent activity","icon":"Clock","color":"#74b9ff","route":"","category":"Widgets"}' },
      { config_key: "widget_topics",   position: -3, config_value: '{"title":"Topics","description":"Most replies","icon":"Replies","color":"#F5A623","route":"","category":"Widgets"}' },
      { config_key: "widget_popular",  position: -2, config_value: '{"title":"Popular","description":"Most viewed","icon":"Chart","color":"#4CAF50","route":"","category":"Widgets"}' },
      { config_key: "widget_liked",    position: -1, config_value: '{"title":"Liked","description":"Most reactions","icon":"Likes","color":"#ff6b6b","route":"","category":"Widgets"}' },
    ]

    widgets.each do |item|
      escaped = item[:config_value].gsub("'", "''")
      execute <<~SQL
        INSERT INTO domniq_app_configs (brand_key, config_type, config_key, config_value, position, enabled, created_at, updated_at)
        VALUES ('#{brand}', 'drawer', '#{item[:config_key]}', '#{escaped}', #{item[:position]}, true, '#{now}', '#{now}')
        ON CONFLICT DO NOTHING
      SQL
    end
  end

  def down
    execute <<~SQL
      DELETE FROM domniq_app_configs
      WHERE brand_key = 'domniq'
        AND config_type = 'drawer'
        AND config_key IN (
          'widget_activity',
          'widget_topics',
          'widget_popular',
          'widget_liked'
        )
    SQL
  end
end
