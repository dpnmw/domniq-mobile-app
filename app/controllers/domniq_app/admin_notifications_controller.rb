# frozen_string_literal: true

module DomniqApp
  class AdminNotificationsController < ::Admin::AdminController
    requires_plugin DomniqApp::PLUGIN_NAME

    def settings
      subscriptions = ExpoSubscription
        .joins(:user)
        .select(
          "domniq_app_expo_subscriptions.id",
          "domniq_app_expo_subscriptions.expo_pn_token",
          "domniq_app_expo_subscriptions.platform",
          "domniq_app_expo_subscriptions.application_name",
          "domniq_app_expo_subscriptions.created_at",
          "users.id AS user_id",
          "users.username",
        )
        .order(created_at: :desc)
        .limit(100)

      render json: {
        push_notifications_enabled: SiteSetting.domniq_app_push_notifications_enabled,
        subscriptions: subscriptions.map { |s|
          {
            id:               s.id,
            user_id:          s.user_id,
            username:         s.username,
            platform:         s.platform,
            token:            mask_token(s.expo_pn_token),
            application_name: s.application_name,
            created_at:       s.created_at,
          }
        },
        total_subscriptions: ExpoSubscription.count,
      }
    end

    def update_settings
      if params.key?(:push_notifications_enabled)
        SiteSetting.domniq_app_push_notifications_enabled =
          ActiveModel::Type::Boolean.new.cast(params[:push_notifications_enabled])
      end
      render json: success_json
    end

    def remove_subscription
      sub = ExpoSubscription.find_by(id: params[:id])
      sub&.destroy
      render json: success_json
    end

    def test_push
      sub = ExpoSubscription.find_by(id: params[:subscription_id])
      return render json: { error: "Subscription not found" }, status: :not_found unless sub

      user = User.find_by(id: sub.user_id)
      return render json: { error: "User not found" }, status: :not_found unless user

      DomniqApp::PushSender.notify_user(
        user,
        title: "#{SiteSetting.title}",
        body:  "This is a test push notification.",
        data:  { notification_type: "test" },
      )

      render json: success_json
    end

    private

    def mask_token(token)
      return token if token.length <= 16
      "#{token[0..11]}...#{token[-4..]}"
    end
  end
end
