# frozen_string_literal: true

class CreateDomniqAppExpoSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :domniq_app_expo_subscriptions do |t|
      t.integer :user_id, null: false
      t.string :expo_pn_token, null: false
      t.string :experience_id, null: false
      t.string :application_name, null: false
      t.string :platform, null: false
      t.string :brand_key, default: "domniq"
      t.integer :user_auth_token_id
      t.timestamps
    end

    add_index :domniq_app_expo_subscriptions, [:expo_pn_token], unique: true
    add_foreign_key :domniq_app_expo_subscriptions, :users, column: :user_id
    add_foreign_key :domniq_app_expo_subscriptions, :user_auth_tokens, column: :user_auth_token_id, on_delete: :cascade
  end
end
