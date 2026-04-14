# frozen_string_literal: true

module DomniqApp
  class PushNotificationManager
    def self.send_notification(push_notification:, expo_pn_subscriptions:)
      content = NotificationContent.generate(
        push_notification.notification_type,
        push_notification.username,
        push_notification.topic_title,
        push_notification.excerpt,
        push_notification.channel_name,
      )

      client = Expo::Push::Client.new
      experience_id_group = build_experience_id_groups(expo_pn_subscriptions)

      experience_id_group.each do |_experience_id, expo_pn_tokens|
        messages = []

        expo_pn_tokens.each do |expo_pn_token|
          unless Expo::Push.expo_push_token?(expo_pn_token)
            Rails.logger.error("Push token #{expo_pn_token} is not a valid Expo push token")
            ExpoSubscription.where(expo_pn_token: expo_pn_token).destroy_all
            next
          end

          messages << client
            .notification
            .to(expo_pn_token)
            .sound("default")
            .title(content[:title])
            .body(content[:body])
            .data(
              {
                "discourse_url" => push_notification.post_url,
                "type" => push_notification.notification_type,
                "is_pm" => push_notification.is_pm,
                "is_chat" => push_notification.is_chat,
                "is_thread" => push_notification.is_thread,
              },
            )
        end

        next if messages.empty?

        tickets = client.send(messages)
        process_tickets(tickets, push_notification, tokens: expo_pn_tokens)
      end
    end

    def self.process_tickets(tickets, push_notification, opts)
      should_retry = false

      tickets.each_error do |ticket_error|
        if ticket_error.is_a?(Expo::Push::PushTokenInvalid)
          ExpoSubscription.where(expo_pn_token: ticket_error.token).destroy_all
        elsif ticket_error.is_a?(Expo::Push::TicketsWithErrors)
          ticket_error.errors.each do |error_data|
            should_retry = true
            if error_data["code"] == "PUSH_TOO_MANY_EXPERIENCE_IDS"
              error_data["details"].each do |correct_experience, tokens|
                instances = ExpoSubscription.where.not(experience_id: correct_experience).where(expo_pn_token: tokens)
                next if instances.blank?
                instances.update_all(experience_id: correct_experience)
              end
            else
              Rails.logger.error("DomniqApp::PushNotificationManager: #{error_data}")
            end
          end
        elsif ticket_error.respond_to?(:explain)
          original_token = ticket_error.original_push_token
          ExpoSubscription.where(expo_pn_token: original_token).destroy_all if original_token
        else
          Rails.logger.error("DomniqApp::PushNotificationManager: #{ticket_error}")
        end
      end

      retry_push_notification(tokens: opts[:tokens], push_notification_id: push_notification.id) if should_retry

      ReceiptsManager.queue_receipts(tickets, push_notification)
    end

    def self.retry_push_notification(tokens:, push_notification_id:)
      PushNotificationRetry.where(push_notification_id: push_notification_id, token: tokens).update_all(
        ["retry_count = retry_count + 1, updated_at = ?", Time.current],
      )

      existing = PushNotificationRetry.where(push_notification_id: push_notification_id, token: tokens)
      new_tokens = tokens - existing.map(&:token)

      new_retries = new_tokens.map do |token|
        { token: token, push_notification_id: push_notification_id, retry_count: 1 }
      end
      created = PushNotificationRetry.create(new_retries)
      all_retries = existing + created

      eligible = all_retries.select(&:eligible_to_retry)
      eligible.group_by(&:retry_count).each do |retry_count, records|
        Jobs.enqueue_in(
          PushNotificationRetry.calculate_retry_time(retry_count),
          :domniq_app_send_push_notification,
          retry_ids: records.map(&:id),
        )
      end

      excessive_ids = all_retries.reject(&:eligible_to_retry).map(&:id)
      if excessive_ids.present?
        PushNotificationRetry.where(id: excessive_ids).delete_all
        Rails.logger.error("DomniqApp::PushNotificationManager: Excessive retries for push_notification_id: #{push_notification_id}")
      end
    end

    def self.build_experience_id_groups(expo_pn_subscriptions)
      experience_id_group = Hash.new { |hash, key| hash[key] = [] }

      expo_pn_subscriptions.each do |sub|
        expo_pn_token = sub.respond_to?(:expo_pn_token) ? sub.expo_pn_token : sub[:expo_pn_token]
        experience_id = sub.respond_to?(:experience_id) ? sub.experience_id : sub[:experience_id]
        experience_id_group[experience_id].push(expo_pn_token)
      end

      experience_id_group
    end
  end
end
