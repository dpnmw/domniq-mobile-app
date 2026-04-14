# frozen_string_literal: true

class CreateDomniqAppPushNotificationReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :domniq_app_push_notification_receipts do |t|
      t.integer :push_notification_id
      t.string :token
      t.string :receipt_id
      t.timestamps
    end

    add_index :domniq_app_push_notification_receipts, [:receipt_id], unique: true
    add_foreign_key :domniq_app_push_notification_receipts, :domniq_app_push_notifications, column: :push_notification_id
  end
end
