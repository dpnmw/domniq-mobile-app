# frozen_string_literal: true

module DomniqApp
  class PushNotification < ActiveRecord::Base
    self.table_name = "#{DomniqApp.table_name_prefix}push_notifications"

    has_many :push_notification_retries, class_name: "DomniqApp::PushNotificationRetry"
    has_many :push_notification_receipts, class_name: "DomniqApp::PushNotificationReceipt"
  end
end
