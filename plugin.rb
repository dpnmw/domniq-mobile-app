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

  # Force-load push models and controller so they are available
  # regardless of whether push is currently enabled.
  load File.expand_path("app/models/domniq_app/expo_subscription.rb", __dir__)
  load File.expand_path("app/models/domniq_app/push_receipt.rb", __dir__)
  load File.expand_path("app/controllers/domniq_app/push_controller.rb", __dir__)

  # Load push jobs
  require_relative "app/jobs/regular/domniq_send_push_notification"
  require_relative "app/jobs/scheduled/domniq_check_push_receipts"

  # Hook into Discourse notifications.
  # Guard is INSIDE the block so toggling the setting takes effect immediately
  # without requiring a server restart.
  DiscourseEvent.on(:notification_created) do |notification|
    next unless SiteSetting.domniq_app_push_notifications_enabled

    user = notification.user
    next unless user
    # Skip if user has already seen this notification
    next if user.seen_notification_id.to_i >= notification.id

    topic = notification.topic
    title = topic&.title.presence || SiteSetting.title
    username = notification.data_hash[:display_username].to_s

    body =
      case notification.notification_type
      when Notification.types[:mentioned],
           Notification.types[:group_mentioned]
        "#{username} mentioned you in #{title}"
      when Notification.types[:replied]
        "#{username} replied to your post in #{title}"
      when Notification.types[:quoted]
        "#{username} quoted your post in #{title}"
      when Notification.types[:liked]
        "#{username} liked your post in #{title}"
      when Notification.types[:private_message]
        title = "New Message"
        "#{username} sent you a message"
      when Notification.types[:posted]
        "New post in #{title}"
      when Notification.types[:watching_first_post]
        "New topic: #{title}"
      when Notification.types[:chat_mention],
           Notification.types[:chat_message]
        channel = notification.data_hash[:chat_channel_title].to_s
        title = "Chat"
        "#{username} in #{channel}"
      else
        "#{username} — #{title}"
      end

    data = {
      notification_type: notification.notification_type.to_s,
      topic_id:          topic&.id,
      topic_title:       topic&.title,
      post_url:          notification.url,
      post_number:       notification.post_number,
      is_pm:             notification.notification_type == Notification.types[:private_message],
      is_chat:           [
                           Notification.types[:chat_mention],
                           Notification.types[:chat_message],
                         ].include?(notification.notification_type),
      chat_channel_id:    notification.data_hash[:chat_channel_id],
      chat_channel_title: notification.data_hash[:chat_channel_title],
    }.compact

    Jobs.enqueue(
      :domniq_send_push_notification,
      user_id: user.id,
      title:   title,
      body:    body,
      data:    data,
    )
  end

  # Video thumbnails
  if SiteSetting.domniq_app_video_thumbnails_enabled
    require_relative "lib/domniq_app/video_thumbnail_patch"
  end

  # Telemetry heartbeat
  require_relative "app/jobs/scheduled/domniq_heartbeat"
end
