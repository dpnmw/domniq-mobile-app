# frozen_string_literal: true

module DomniqApp
  class ApplicationController < ::ApplicationController
    requires_plugin ::DomniqApp::PLUGIN_NAME

    before_action :ensure_logged_in
    before_action :ensure_enabled!

    private

    def ensure_enabled!
      unless DomniqApp.enabled?
        raise Discourse::InvalidAccess.new(I18n.t("domniq_app.errors.not_enabled"))
      end
    end

    def guardian
      @guardian ||= Guardian.new(current_user)
    end
  end
end
