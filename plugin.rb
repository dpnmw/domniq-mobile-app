# frozen_string_literal: true

# name: domniq-mobile-app
# about: Domniq Mobile App — video thumbnails, remote app configuration, translations, and licensing
# version: 1.0.0
# authors: DPN Media Works
# url: https://dpnmediaworks.com

enabled_site_setting :domniq_app_enabled

register_asset "stylesheets/common/domniq-admin.scss", :admin

add_admin_route "domniq_app.admin.title", "domniq-mobile-app", use_new_show_route: true

require_relative "lib/domniq_app"

after_initialize do
  Discourse::Application.routes.append { mount ::DomniqApp::Engine, at: "/domniq-app" }

  # --- Video Thumbnails ---
  if SiteSetting.domniq_app_video_thumbnails_enabled
    require_relative "lib/domniq_app/video_thumbnail_patch"
  end

  # --- Telemetry Heartbeat ---
  require_relative "app/jobs/scheduled/domniq_heartbeat"
end
