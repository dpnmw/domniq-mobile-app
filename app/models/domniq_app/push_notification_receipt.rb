# frozen_string_literal: true

module DomniqApp
  class PushNotificationReceipt < ActiveRecord::Base
    self.table_name = "#{DomniqApp.table_name_prefix}push_notification_receipts"

    belongs_to :push_notification, class_name: "DomniqApp::PushNotification"
  end
end
