# frozen_string_literal: true

module DomniqApp
  class PushController < ApplicationController
    def subscribe
      expo_pn_token = params.require(:push_notifications_token)
      application_name = params.require(:application_name)
      platform = params.require(:platform)
      experience_id = params.require(:experience_id)

      if %w[ios android].exclude?(platform)
        raise Discourse::InvalidParameters, I18n.t("domniq_app.errors.invalid_platform")
      end

      ExpoSubscription.where(expo_pn_token: expo_pn_token).destroy_all

      record =
        ExpoSubscription.find_or_create_by(
          user_id: current_user.id,
          expo_pn_token: expo_pn_token,
          application_name: application_name,
          platform: platform,
          experience_id: experience_id,
          user_auth_token_id: current_user.user_auth_tokens&.last&.id,
        )

      render json: {
        expo_pn_token: record.expo_pn_token,
        user_id: record.user_id,
      }
    end

    def unsubscribe
      expo_pn_token = params.require(:push_notifications_token)

      ExpoSubscription
        .where(expo_pn_token: expo_pn_token, user_id: current_user.id)
        .delete_all

      render json: { message: "success" }
    end
  end
end
