# frozen_string_literal: true

module DomniqApp
  BUFFER_TIME = 5.minutes
  RETRY_LIMIT = 10

  class PushNotificationRetry < ActiveRecord::Base
    self.table_name = "#{DomniqApp.table_name_prefix}push_notification_retries"

    belongs_to :push_notification, class_name: "DomniqApp::PushNotification"

    def self.calculate_retry_time(retry_count)
      1.minute * 2**retry_count
    end

    def self.retry_limit
      RETRY_LIMIT
    end

    def retry_time
      updated_at + PushNotificationRetry.calculate_retry_time(retry_count) + BUFFER_TIME
    end

    def eligible_to_retry
      retry_count < RETRY_LIMIT
    end
  end
end
