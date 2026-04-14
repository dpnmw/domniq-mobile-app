# frozen_string_literal: true

class CreateDomniqAppPushNotificationRetries < ActiveRecord::Migration[7.0]
  def change
    create_table :domniq_app_push_notification_retries do |t|
      t.string :token
      t.integer :push_notification_id
      t.integer :retry_count, default: 0
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end

    add_foreign_key :domniq_app_push_notification_retries, :domniq_app_push_notifications, column: :push_notification_id
  end
end
