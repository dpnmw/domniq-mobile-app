# frozen_string_literal: true

module Jobs
  class DomniqAppSendPushNotification < ::Jobs::Base
    sidekiq_options retry: false

    def execute(args)
      if args[:retry_ids].blank?
        payload = args[:payload]
        expo_pn_subscriptions = DomniqApp::ExpoSubscription.where(user_id: args[:user_id])

        push_notification = DomniqApp::PushNotification.create!(
          user_id: args[:user_id],
          username: payload["username"],
          topic_title: payload["topic_title"],
          excerpt: payload["excerpt"],
          notification_type: payload["notification_type"],
          post_url: payload["post_url"],
          is_pm: payload["is_pm"],
          is_chat: payload["is_chat"],
          is_thread: payload["is_thread"],
          channel_name: payload["channel_name"],
        )

        DomniqApp::PushNotificationManager.send_notification(
          push_notification: push_notification,
          expo_pn_subscriptions: expo_pn_subscriptions,
        )
      else
        push_notification_retries = DomniqApp::PushNotificationRetry.where(id: args[:retry_ids])
        retries_by_id = push_notification_retries.group_by(&:push_notification_id)

        retries_by_id.each do |_push_notification_id, retries|
          expo_pn_subscriptions = DomniqApp::ExpoSubscription.where(
            expo_pn_token: retries.map(&:token),
          )
          push_notification = retries.first.push_notification

          DomniqApp::PushNotificationManager.send_notification(
            push_notification: push_notification,
            expo_pn_subscriptions: expo_pn_subscriptions,
          )
        end
      end
    end
  end
end
