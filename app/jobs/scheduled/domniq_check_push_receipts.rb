# frozen_string_literal: true

module Jobs
  class DomniqCheckPushReceipts < ::Jobs::Scheduled
    every 30.minutes

    def execute(_args)
      return unless SiteSetting.domniq_app_push_notifications_enabled
      DomniqApp::PushSender.check_receipts
    end
  end
end
