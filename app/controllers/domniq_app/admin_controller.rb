# frozen_string_literal: true

module DomniqApp
  class AdminController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def index
    end
  end
end
