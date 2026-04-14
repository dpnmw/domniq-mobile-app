# frozen_string_literal: true

class CreateDomniqAppLocaleFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :domniq_app_locale_files do |t|
      t.string :brand_key, null: false, default: "domniq"
      t.string :locale, null: false
      t.string :label, null: false
      t.integer :version, null: false, default: 1
      t.text :po_data, null: false
      t.timestamps
    end

    add_index :domniq_app_locale_files, %i[brand_key locale], unique: true
  end
end
