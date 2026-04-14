# frozen_string_literal: true

module DomniqApp
  class ChatMentionHandler
    def self.handle(notification)
      return unless notification.notification_type == Notification.types[:chat_mention]

      data = JSON.parse(notification.data, symbolize_names: true)
      channel_id, message_id = data.values_at(:chat_channel_id, :chat_message_id)
      return unless channel_id && message_id

      message = Chat::Message.find_by(chat_channel_id: channel_id, id: message_id)
      return unless message

      sender = message.user
      chat_channel = message.chat_channel

      user_subscription = ExpoSubscription.find_by(user_id: notification.user_id)
      return unless user_subscription

      post_url = "/c/#{channel_id}#{message.thread_id ? "/#{message.thread_id}" : ""}/#{message.id}"

      payload = {
        notification_type: notification.notification_type,
        excerpt: message.message,
        username: sender.username,
        post_url: post_url,
        is_chat: true,
        is_thread: message.thread_id.present?,
        channel_name: chat_channel.name,
      }

      Jobs.enqueue(:domniq_app_send_push_notification, payload: payload, user_id: notification.user_id)
    end
  end
end
