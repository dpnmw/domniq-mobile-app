# frozen_string_literal: true

module Jobs
  class DomniqAppCleanupReceipts < ::Jobs::Scheduled
    every 2.hours
    sidekiq_options retry: false

    def execute(_args)
      DomniqApp::PushNotificationReceipt.where("created_at < ?", 1.day.ago).delete_all

      receipts = DomniqApp::PushNotificationReceipt.where("created_at < ?", 20.minutes.ago)
      receipt_ids = receipts.map(&:id)

      if receipt_ids.present?
        Jobs.enqueue(:domniq_app_check_receipt, push_notification_receipt_ids: receipt_ids)
      end
    end
  end
end
