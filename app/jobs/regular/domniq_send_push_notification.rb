# frozen_string_literal: true

module Jobs
  class DomniqSendPushNotification < ::Jobs::Base
    def execute(args)
      return unless SiteSetting.domniq_app_push_notifications_enabled

      user = User.find_by(id: args[:user_id])
      return unless user

      DomniqApp::PushSender.notify_user(
        user,
        title: args[:title].to_s,
        body:  args[:body].to_s,
        data:  (args[:data] || {}).symbolize_keys,
      )
    end
  end
end
