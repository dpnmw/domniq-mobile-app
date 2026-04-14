# frozen_string_literal: true

class CreateDomniqAppPushNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :domniq_app_push_notifications do |t|
      t.integer :user_id
      t.string :username
      t.string :topic_title
      t.text :excerpt
      t.string :notification_type
      t.string :post_url
      t.boolean :is_pm
      t.boolean :is_chat, default: false
      t.boolean :is_thread, default: false
      t.string :channel_name
      t.timestamps
    end

    add_foreign_key :domniq_app_push_notifications, :users, column: :user_id
  end
end
