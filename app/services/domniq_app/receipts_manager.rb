# frozen_string_literal: true

module DomniqApp
  class ReceiptsManager
    def self.queue_receipts(tickets, push_notification)
      token_by_receipt_id = tickets.token_by_receipt_id
      batches = tickets.batch_ids

      batches.each do |current_batch_receipt_ids|
        push_notification_receipt_ids = []

        current_batch_receipt_ids.each do |receipt_id|
          expo_pn_token = token_by_receipt_id[receipt_id]
          receipt = PushNotificationReceipt.create(
            receipt_id: receipt_id,
            token: expo_pn_token,
            push_notification_id: push_notification.id,
          )
          push_notification_receipt_ids << receipt.id
        end

        Jobs.enqueue_in(
          15.minutes,
          :domniq_app_check_receipt,
          push_notification_receipt_ids: push_notification_receipt_ids,
        )
      end
    end

    def self.process_receipts(receipts)
      device_not_registered_receipts = []
      successful_receipts = []
      retryable_receipts = []

      receipts.each_error do |receipt_error|
        if receipt_error.is_a?(Expo::Push::ReceiptsWithErrors)
          receipt_error.errors.each do |error_data|
            Rails.logger.error("DomniqApp::ReceiptsManager: #{error_data}")
          end
        elsif receipt_error.respond_to?(:error_message)
          if receipt_error.error_message == "DeviceNotRegistered"
            device_not_registered_receipts << receipt_error.receipt_id
          elsif receipt_error.error_message == "MessageRateExceeded"
            retryable_receipts << receipt_error.receipt_id
          end
        else
          Rails.logger.error("DomniqApp::ReceiptsManager: #{receipt_error}")
        end
      end

      receipts.each do |receipt|
        successful_receipts << receipt.receipt_id
      end

      cleanup_device_not_registered(device_not_registered_receipts) if device_not_registered_receipts.present?
      retry_receipts(retryable_receipts) if retryable_receipts.present?
      process_finished_receipts(successful_receipts) if successful_receipts.present?
    end

    def self.retry_receipts(receipt_ids)
      push_notification_receipts = PushNotificationReceipt.where(receipt_id: receipt_ids)
      push_notification = push_notification_receipts.first.push_notification
      tokens = push_notification_receipts.map(&:token)

      PushNotificationManager.retry_push_notification(tokens: tokens, push_notification_id: push_notification.id)
      push_notification_receipts.destroy_all
    end

    def self.cleanup_device_not_registered(receipt_ids)
      push_notification_receipts = PushNotificationReceipt.where(receipt_id: receipt_ids)
      ExpoSubscription.where(expo_pn_token: push_notification_receipts.map(&:token)).destroy_all
      process_finished_receipts(receipt_ids)
    end

    def self.process_finished_receipts(receipt_ids)
      push_notification_receipts = PushNotificationReceipt.where(receipt_id: receipt_ids)
      return if push_notification_receipts.empty?

      push_notification_id = push_notification_receipts.first.push_notification_id
      PushNotificationRetry.where(
        token: push_notification_receipts.map(&:token),
        push_notification_id: push_notification_id,
      ).destroy_all
      push_notification_receipts.destroy_all
    end
  end
end
