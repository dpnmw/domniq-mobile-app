# frozen_string_literal: true

module DomniqApp
  class PushController < DomniqApp::ApplicationController
    # Inherits ensure_logged_in and ensure_enabled! from ApplicationController.
    # No skip_before_action calls — none are needed or safe on Rails 8.

    def subscribe
      unless SiteSetting.domniq_app_push_notifications_enabled
        return render json: { error: I18n.t("domniq_app.errors.push_disabled") },
                      status: :unprocessable_entity
      end

      token    = params.require(:push_notifications_token)
      platform = params.require(:platform)

      unless %w[ios android].include?(platform)
        return render json: { error: I18n.t("domniq_app.errors.invalid_platform") },
                      status: :unprocessable_entity
      end

      application_name = params[:application_name].presence || "DOMNiQ"
      experience_id    = params[:experience_id].to_s

      # Token belongs to exactly one user. Remove any prior registration.
      ExpoSubscription.where(expo_pn_token: token).destroy_all

      subscription = ExpoSubscription.create!(
        user_id:          current_user.id,
        expo_pn_token:    token,
        platform:         platform,
        application_name: application_name,
        experience_id:    experience_id,
        brand_key:        "domniq",
        user_auth_token_id: current_user.user_auth_tokens&.last&.id,
      )

      render json: { expo_pn_token: subscription.expo_pn_token,
                     user_id:       subscription.user_id }
    end

    def unsubscribe
      token = params.require(:push_notifications_token)

      ExpoSubscription
        .where(expo_pn_token: token, user_id: current_user.id)
        .destroy_all

      render json: success_json
    end
  end
end
