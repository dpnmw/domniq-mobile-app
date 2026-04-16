# frozen_string_literal: true

module DomniqApp
  class AdminNotificationsController < ::Admin::AdminController
    requires_plugin DomniqApp::PLUGIN_NAME

    def settings
      render json: {
        push_notifications_enabled: SiteSetting.domniq_app_push_notifications_enabled,
        stats: {
          total:   ExpoSubscription.count,
          ios:     ExpoSubscription.where(platform: "ios").count,
          android: ExpoSubscription.where(platform: "android").count,
        },
      }
    end

    def search
      username = params[:username].to_s.strip.downcase
      return render json: { subscriptions: [] } if username.blank?

      user = User.find_by("lower(username) = ?", username)
      return render json: { subscriptions: [] } unless user

      subscriptions = ExpoSubscription
        .where(user_id: user.id)
        .order(created_at: :desc)

      render json: {
        subscriptions: subscriptions.map { |s|
          {
            id:               s.id,
            username:         user.username,
            user_id:          user.id,
            platform:         s.platform,
            token:            mask_token(s.expo_pn_token),
            application_name: s.application_name,
            created_at:       s.created_at,
          }
        },
      }
    end

    def cleanup
      deleted = ExpoSubscription
        .where(
          "user_auth_token_id IS NULL OR user_auth_token_id NOT IN (SELECT id FROM user_auth_tokens)"
        )
        .delete_all

      render json: { deleted: deleted }
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
