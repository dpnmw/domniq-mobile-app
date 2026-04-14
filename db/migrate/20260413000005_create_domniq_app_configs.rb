# frozen_string_literal: true

class CreateDomniqAppConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :domniq_app_configs do |t|
      t.string :brand_key, null: false, default: "domniq"
      t.string :config_type, null: false
      t.string :config_key, null: false
      t.text :config_value, null: false
      t.integer :position, default: 0
      t.boolean :enabled, default: true
      t.timestamps
    end

    add_index :domniq_app_configs, %i[brand_key config_type config_key], unique: true, name: "idx_domniq_app_configs_unique"
  end
end
