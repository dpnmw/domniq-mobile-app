# frozen_string_literal: true

# name: domniq-mobile-app
# about: Domniq Mobile App — video thumbnails, remote app configuration, translations, and licensing
# version: 1.0.0
# authors: DPN Media Works
# url: https://dpnmediaworks.com

enabled_site_setting :domniq_app_enabled

register_asset "stylesheets/common/domniq-admin.scss", :admin

register_svg_icon "mobile-screen"

add_admin_route "domniq_app.admin.title", "domniq-mobile-app", use_new_show_route: true

require_relative "lib/domniq_app"

after_initialize do
  Discourse::Application.routes.append { mount ::DomniqApp::Engine, at: "/domniq-app" }

  # Auto-register this site's auth redirect URL so mobile app users can log in
  # without the admin having to add <base_url>/auth_redirect by hand.
  # Idempotent — no-op if already present. Only fires when plugin is enabled.
  ensure_auth_redirect = -> {
    next unless SiteSetting.domniq_app_enabled
    required = "#{Discourse.base_url}/auth_redirect"
    current = SiteSetting.allowed_user_api_auth_redirects.to_s.split("|").reject(&:blank?)
    next if current.include?(required)
    SiteSetting.allowed_user_api_auth_redirects = (current + [required]).join("|")
    Rails.logger.info("[DomniqApp] Registered auth redirect: #{required}")
  }
  ensure_auth_redirect.call
  DiscourseEvent.on(:site_setting_changed) do |name, _old, new_val|
    ensure_auth_redirect.call if name == :domniq_app_enabled && new_val
  end

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

    # Resolve the triggering post for excerpt extraction. notification.post
    # walks topic_id + post_number to find the Post. Nil for notifications
    # that don't have an associated post (badges, admin messages).
    post =
      begin
        notification.post
      rescue StandardError
        nil
      end

    # Discourse's Post#excerpt strips markup, handles quoted text, truncates
    # at word boundaries, preserves emoji shortcodes. 140 chars fits within
    # Android/iOS notification body truncation limits while leaving room for
    # the "username:" prefix.
    post_excerpt =
      if post
        begin
          post.excerpt(140, strip_links: true, text_entities: true)
        rescue StandardError
          nil
        end
      end

    # Chat messages store their excerpt directly in data_hash. Fall back
    # to loading ChatMessage if message_excerpt isn't present.
    chat_excerpt =
      if [Notification.types[:chat_mention], Notification.types[:chat_message]]
           .include?(notification.notification_type)
        notification.data_hash[:message_excerpt].to_s.presence ||
          begin
            if defined?(Chat::Message) && notification.data_hash[:chat_message_id]
              Chat::Message
                .find_by(id: notification.data_hash[:chat_message_id])
                &.excerpt(140)
            end
          rescue StandardError
            nil
          end
      end

    body =
      case notification.notification_type
      when Notification.types[:mentioned],
           Notification.types[:group_mentioned]
        post_excerpt.present? ? "#{username}: #{post_excerpt}" : "#{username} mentioned you in #{title}"
      when Notification.types[:replied]
        post_excerpt.present? ? "#{username}: #{post_excerpt}" : "#{username} replied to your post in #{title}"
      when Notification.types[:quoted]
        post_excerpt.present? ? "#{username} quoted you: #{post_excerpt}" : "#{username} quoted your post in #{title}"
      when Notification.types[:liked]
        "#{username} liked your post in #{title}"
      when Notification.types[:private_message]
        title = "New Message"
        post_excerpt.present? ? "#{username}: #{post_excerpt}" : "#{username} sent you a message"
      when Notification.types[:posted]
        post_excerpt.present? ? "#{username}: #{post_excerpt}" : "New post in #{title}"
      when Notification.types[:watching_first_post]
        post_excerpt.present? ? "#{username}: #{post_excerpt}" : "New topic: #{title}"
      when Notification.types[:chat_mention],
           Notification.types[:chat_message]
        channel = notification.data_hash[:chat_channel_title].to_s
        title = "Chat"
        chat_excerpt.present? ? "#{username} in #{channel}: #{chat_excerpt}" : "#{username} in #{channel}"
      else
        "#{username} — #{title}"
      end

    data = {
      notification_type: notification.notification_type.to_s,
      topic_id:          topic&.id,
      topic_title:       topic&.title,
      post_url:          notification.url,
      base_url:          Discourse.base_url,
      post_number:       notification.post_number,
      is_pm:             notification.notification_type == Notification.types[:private_message],
      is_chat:           [
                           Notification.types[:chat_mention],
                           Notification.types[:chat_message],
                         ].include?(notification.notification_type),
      chat_channel_id:    notification.data_hash[:chat_channel_id],
      chat_channel_title: notification.data_hash[:chat_channel_title],
      chat_message_id:    notification.data_hash[:chat_message_id],
      chat_thread_id:     notification.data_hash[:chat_thread_id],
    }.compact

    Jobs.enqueue(
      :domniq_send_push_notification,
      user_id: user.id,
      title:   title,
      body:    body,
      data:    data,
    )
  end

  # Video thumbnails — always load the patch; the SiteSetting is checked
  # at call-time inside update_post_image so admins can toggle it live
  # without a server restart.
  require_relative "lib/domniq_app/video_thumbnail_patch"

  # Telemetry heartbeat
  require_relative "app/jobs/scheduled/domniq_heartbeat"
end
