# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "zlib"
require "stringio"

module DomniqApp
  class PushSender
    EXPO_SEND_URL     = "https://exp.host/--/api/v2/push/send"
    EXPO_RECEIPTS_URL = "https://exp.host/--/api/v2/push/getReceipts"
    SEND_BATCH_SIZE    = 100
    RECEIPT_BATCH_SIZE = 1000

    # Send a push notification to all devices registered to a user.
    def self.notify_user(user, title:, body:, data: {})
      subscriptions = ExpoSubscription.where(user_id: user.id)
      return if subscriptions.empty?

      messages = subscriptions.map do |sub|
        {
          to:        sub.expo_pn_token,
          title:     title,
          body:      body,
          data:      data,
          sound:     "default",
          priority:  "high",
          channelId: "default",
        }
      end

      messages.each_slice(SEND_BATCH_SIZE) do |batch|
        response = post_to_expo(EXPO_SEND_URL, batch)
        next unless response&.dig("data")

        response["data"].each_with_index do |ticket, idx|
          token = batch[idx][:to]

          case ticket["status"]
          when "ok"
            receipt_id = ticket["id"]
            PushReceipt.create(token: token, receipt_id: receipt_id) if receipt_id.present?
          when "error"
            handle_send_error(ticket, token)
          end
        end
      end
    end

    # Check Expo delivery receipts for previously sent notifications.
    # Called by the scheduled job every 30 minutes.
    def self.check_receipts
      # Only check receipts older than 15 min (Expo needs time to process)
      # and younger than 24 hours (Expo discards older ones).
      pending = PushReceipt
                  .where("created_at < ?", 15.minutes.ago)
                  .where("created_at > ?", 24.hours.ago)
      return if pending.empty?

      pending.find_in_batches(batch_size: RECEIPT_BATCH_SIZE) do |batch|
        ids = batch.map(&:receipt_id)

        response = post_to_expo(EXPO_RECEIPTS_URL, { ids: ids })

        if response&.dig("data")
          response["data"].each do |receipt_id, receipt|
            next unless receipt["status"] == "error"

            if receipt.dig("details", "error") == "DeviceNotRegistered"
              record = batch.find { |r| r.receipt_id == receipt_id }
              ExpoSubscription.where(expo_pn_token: record.token).destroy_all if record
            end
          end
        end

        # Always clean up checked receipts to prevent table bloat.
        PushReceipt.where(id: batch.map(&:id)).delete_all
      end
    end

    private

    def self.handle_send_error(ticket, token)
      error = ticket.dig("details", "error")
      if error == "DeviceNotRegistered"
        ExpoSubscription.where(expo_pn_token: token).destroy_all
      else
        Rails.logger.warn(
          "[DomniqApp::PushSender] Delivery error for token #{token[0..11]}...: #{error}"
        )
      end
    end

    def self.post_to_expo(url, payload)
      uri     = URI.parse(url)
      http    = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = true
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"]    = "application/json"
      request["Accept"]          = "application/json"
      request["Accept-Encoding"] = "gzip, deflate"
      request.body = payload.to_json

      response = http.request(request)

      unless response.code.to_i == 200
        Rails.logger.warn(
          "[DomniqApp::PushSender] Expo returned HTTP #{response.code}"
        )
        return nil
      end

      body = response.body
      if response["Content-Encoding"] == "gzip"
        body = Zlib::GzipReader.new(StringIO.new(body)).read
      end

      JSON.parse(body)
    rescue StandardError => e
      Rails.logger.error("[DomniqApp::PushSender] Request failed: #{e.message}")
      nil
    end
  end
end
