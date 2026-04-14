# frozen_string_literal: true

module Jobs
  class DomniqAppCheckReceipt < ::Jobs::Base
    sidekiq_options retry: false

    def execute(args)
      push_notification_receipt_ids = args[:push_notification_receipt_ids]
      push_notification_receipts = DomniqApp::PushNotificationReceipt.where(id: push_notification_receipt_ids)
      receipt_ids = push_notification_receipts.map(&:receipt_id)

      client = Expo::Push::Client.new
      receipts = client.receipts(receipt_ids)

      DomniqApp::ReceiptsManager.process_receipts(receipts)
    end
  end
end
