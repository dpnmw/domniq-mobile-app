# frozen_string_literal: true

module DomniqApp
  class AdminNotificationsController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def index
      subscriptions = ExpoSubscription.includes(:user).order(created_at: :desc)

      render json: {
        subscriptions: subscriptions.map { |s|
          {
            id: s.id,
            user_id: s.user_id,
            username: s.user&.username,
            avatar_template: s.user&.avatar_template,
            platform: s.platform,
            expo_pn_token: s.expo_pn_token,
            created_at: s.created_at,
          }
        },
      }
    end

    def destroy
      subscription = ExpoSubscription.find(params[:id])
      subscription.destroy!

      render json: success_json
    end

    def test_push
      subscription = ExpoSubscription.find(params[:subscription_id])

      push_notification = PushNotification.create!(
        user_id: subscription.user_id,
        username: current_user.username,
        topic_title: "Test Notification",
        excerpt: "This is a test push notification from Domniq Mobile App admin.",
        notification_type: "test",
        post_url: "/",
        is_pm: false,
        is_chat: false,
        is_thread: false,
      )

      PushNotificationManager.send_notification(
        push_notification: push_notification,
        expo_pn_subscriptions: [subscription],
      )

      render json: success_json
    end
  end
end
