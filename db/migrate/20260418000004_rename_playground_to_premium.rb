# frozen_string_literal: true

class RenamePlaygroundToPremium < ActiveRecord::Migration[7.0]
  # Renames the "Playground" drawer category to "Premium" on live servers.
  #
  # Drawer items store their category inside the JSON config_value text column
  # (e.g. {"title":"Audio Bar", ... ,"category":"Playground", ...}). The substring
  # "\"category\":\"Playground\"" is unambiguous across all drawer rows — it's
  # the exact serialized form our seed uses — so a string REPLACE is safe and
  # doesn't require JSONB parsing.
  def up
    execute <<~SQL
      UPDATE domniq_app_configs
      SET config_value = REPLACE(config_value, '"category":"Playground"', '"category":"Premium"'),
          updated_at = NOW()
      WHERE brand_key = 'domniq'
        AND config_type = 'drawer'
        AND config_value LIKE '%"category":"Playground"%'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE domniq_app_configs
      SET config_value = REPLACE(config_value, '"category":"Premium"', '"category":"Playground"'),
          updated_at = NOW()
      WHERE brand_key = 'domniq'
        AND config_type = 'drawer'
        AND config_value LIKE '%"category":"Premium"%'
    SQL
  end
end
