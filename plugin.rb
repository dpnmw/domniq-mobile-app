# frozen_string_literal: true

# name: domniq-mobile-app
# about: Domniq Mobile App — push notifications, video thumbnails, remote app configuration, translations, and licensing
# version: 1.0.0
# authors: DPN Media Works
# url: https://dpnmediaworks.com

gem "domain_name", "0.5.20190701"
gem "http-cookie", "1.0.5"
gem "ffi", "1.17.2"
gem "ffi-compiler", "1.3.2", require_name: "ffi-compiler/loader"
gem "llhttp-ffi", "0.4.0", require_name: "llhttp"
gem "http-form_data", "2.3.0", require_name: "http/form_data"
gem "http", "5.1.1"

require_relative "lib/expo_server_sdk/expo/server/sdk"

enabled_site_setting :domniq_app_enabled

register_asset "stylesheets/common/domniq-admin.scss", :admin

add_admin_route "domniq_app.admin.title", "domniq-mobile-app", use_new_show_route: true

require_relative "lib/domniq_app"

after_initialize do
  Discourse::Application.routes.append { mount ::DomniqApp::Engine, at: "/domniq-app" }

  # --- Push Notifications ---
  if SiteSetting.domniq_app_push_notifications_enabled
    User.class_eval { has_many :domniq_app_expo_subscriptions, class_name: "DomniqApp::ExpoSubscription", dependent: :delete_all }

    DiscourseEvent.on(:before_create_notification) do |user, type, post, opts|
      if user.domniq_app_expo_subscriptions.exists?
        payload = {
          notification_type: type,
          post_number: post.post_number,
          topic_title: post.topic.title,
          topic_id: post.topic.id,
          excerpt:
            post.excerpt(
              400,
              text_entities: true,
              strip_links: true,
              remap_emoji: true,
            ),
          username: type == Notification.types[:liked] ? opts[:display_username] : post.username,
          post_url: post.url,
          is_pm: post.topic.private_message?,
        }
        Jobs.enqueue(
          :domniq_app_send_push_notification,
          payload: payload,
          user_id: user.id,
        )
      end
    end

    DiscourseEvent.on(:notification_created) do |notification|
      DomniqApp::ChatMentionHandler.handle(notification)
    end
  end

  # --- Video Thumbnails ---
  if SiteSetting.domniq_app_video_thumbnails_enabled
    require_relative "lib/domniq_app/video_thumbnail_patch"
  end
end
