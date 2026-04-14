# frozen_string_literal: true

module Jobs
  class DomniqAppCleanupRetries < ::Jobs::Scheduled
    every 2.hours
    sidekiq_options retry: false

    def execute(_args)
      DomniqApp::PushNotificationRetry.where("retry_count >= ?", DomniqApp::PushNotificationRetry.retry_limit).delete_all

      eligible = DomniqApp::PushNotificationRetry.where("retry_count < ?", DomniqApp::PushNotificationRetry.retry_limit)
      retries_by_notification = eligible.group_by(&:push_notification_id)

      retries_by_notification.each do |push_notification_id, retry_records|
        retry_tokens = []

        retry_records.each do |retry_record|
          next unless retry_record.retry_time < Time.current

          retry_tokens << retry_record.token
        end

        next unless retry_tokens.present?

        DomniqApp::PushNotificationManager.retry_push_notification(
          tokens: retry_tokens,
          push_notification_id: push_notification_id,
        )
      end
    end
  end
end
