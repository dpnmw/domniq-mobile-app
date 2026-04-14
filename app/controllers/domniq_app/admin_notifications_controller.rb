# frozen_string_literal: true

module DomniqApp
  class AdminNotificationsController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def settings
      render json: {
        push_notifications_enabled: SiteSetting.domniq_app_push_notifications_enabled,
        subscriptions: [],
      }
    end

    def update_settings
      if params.key?(:push_notifications_enabled)
        SiteSetting.domniq_app_push_notifications_enabled =
          ActiveModel::Type::Boolean.new.cast(params[:push_notifications_enabled])
      end

      render json: success_json
    end
  end
end
