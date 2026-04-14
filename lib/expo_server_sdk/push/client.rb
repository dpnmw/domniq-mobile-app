# frozen_string_literal: true

require "connection_pool"
require "http"

require_relative "./chunk"
require_relative "./notification"
require_relative "./receipts"
require_relative "./tickets"

module Expo
  module Push
    class Error < StandardError
      def self.explain(error)
        identifier = error.is_a?(String) ? error : error.fetch("details").fetch("error")

        case identifier
        when "DeviceNotRegistered"
          "The device cannot receive push notifications anymore and you" \
            " should stop sending messages to the corresponding Expo push token."
        when "InvalidCredentials"
          "Your push notification credentials for your standalone app are " \
            "invalid (ex: you may have revoked them)."
        when "MessageTooBig"
          "The total notification payload was too large. On Android and iOS " \
            "the total payload must be at most 4096 bytes."
        when "MessageRateExceeded"
          "You are sending messages too frequently to the given device. " \
            "Implement exponential backoff and slowly retry sending messages."
        else
          "There is no embedded explanation for #{identifier}. Sorry!"
        end
      rescue KeyError
        "There is no identifier given to explain"
      end
    end

    class ServerError < Error; end
    class ArgumentError < Error; end

    class TicketsWithErrors < Error
      attr_reader :data, :errors

      def initialize(errors:, data:)
        self.data = data
        self.errors = errors

        if errors.length.zero?
          super "Expected at least one error, but got none"
          return
        end

        super "Expo indicated one or more problems: #{errors.map { |error| error['message'] }}"
      end

      private

      attr_writer :data, :errors
    end

    class TicketsExpectationFailed < Error
      attr_reader :data

      def initialize(expected_count:, data:)
        self.data = data

        super format(
          "Expected %<count>s ticket#{expected_count != 1 ? 's' : ''}, actual: %<actual>s. The response data can be inspected.",
          count: expected_count,
          actual: data.is_a?(Array) ? data.length : "<not a list of tickets>",
        )
      end

      private

      attr_writer :data
    end

    class ReceiptsWithErrors < Error
      attr_reader :data, :errors

      def initialize(errors:, data:)
        self.data = data
        self.errors = errors

        if errors.length.zero?
          super "Expected at least one error, but got none"
          return
        end

        super "Expo indicated one or more problems: #{errors.map { |error| error[:message] }}"
      end

      private

      attr_writer :data, :errors
    end

    class PushTokenInvalid < Error
      attr_reader :token

      def initialize(token:)
        self.token = token

        super "Expected a valid Expo Push Token, actual: #{token}"
      end

      private

      attr_writer :token
    end

    PUSH_NOTIFICATION_CHUNK_LIMIT = 100
    PUSH_NOTIFICATION_RECEIPT_CHUNK_LIMIT = 300
    DEFAULT_CONCURRENT_REQUEST_LIMIT = 6

    BASE_URL = "https://exp.host"
    BASE_API_URL = "/--/api/v2"

    PUSH_API_URL = "#{BASE_API_URL}/push/send"
    RECEIPTS_API_URL = "#{BASE_API_URL}/push/getReceipts"

    def self.expo_push_token?(token)
      return false unless token

      /\AExpo(?:nent)?PushToken\[[^\]]+\]\z/.match?(token) ||
        /\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\z/i.match?(token)
    end

    class Client
      def initialize(
        access_token: nil,
        concurrency: DEFAULT_CONCURRENT_REQUEST_LIMIT,
        logger: false,
        instrumentation: false
      )
        self.access_token = access_token
        self.concurrency = concurrency
        self.logger = logger
        self.instrumentation =
          if instrumentation == true
            { instrumentation: ActiveSupport::Notifications.instrumenter }
          else
            instrumentation
          end
      end

      def send(notifications)
        connect unless pool?

        threads =
          Chunk.for(notifications).map do |chunk|
            expected_count = chunk.count
            tokens = chunk.all_recipients
            Thread.new do
              pool.with do |http|
                response = http.post(PUSH_API_URL, json: chunk.as_json)
                parsed_response = response.parse

                data = parsed_response["data"]
                errors = parsed_response["errors"]

                if errors&.length&.positive?
                  TicketsWithErrors.new(data: data, errors: errors)
                elsif !data.is_a?(Array) || data.length != expected_count
                  TicketsExpectationFailed.new(expected_count: expected_count, data: data)
                else
                  data.map do |ticket|
                    current_ticket_token = tokens.shift(1)[0]
                    Ticket.new(ticket, current_ticket_token)
                  end
                end
              end
            end
          end

        Tickets.new(threads.map(&:value))
      end

      def send!(notifications)
        send(notifications).tap do |result|
          result.each_error { |error| raise error if error.is_a?(Error) }
        end
      end

      def receipts(receipt_ids)
        connect unless pool?

        pool.with do |http|
          response = http.post(RECEIPTS_API_URL, json: { ids: Array(receipt_ids) })
          parsed_response = response.parse

          if !parsed_response || parsed_response.is_a?(Array) || !parsed_response.is_a?(Hash)
            raise ServerError, "Expected hash with receipt id => receipt, but got some other data structure"
          end

          errors = parsed_response["errors"]
          data = parsed_response["data"]

          if errors&.length&.positive?
            ReceiptsWithErrors.new(data: parsed_response, errors: errors)
          else
            results =
              data.map do |receipt_id, receipt_value|
                Receipt.new(data: receipt_value, receipt_id: receipt_id)
              end

            Receipts.new(results: results, requested_ids: receipt_ids)
          end
        end
      end

      def connect
        shutdown

        self.pool =
          ConnectionPool.new(size: concurrency, timeout: 5) do
            http =
              HTTP.headers(
                Accept: "application/json",
                "Accept-Encoding": "gzip",
                "User-Agent":
                  format("expo-server-sdk-ruby/%<version>s", version: VERSION),
              )

            http = http.headers("Authorization", "Bearer #{access_token}") if access_token
            http = http.use(:auto_inflate)
            http = http.use(logging: { logger: logger }) if logger
            http = http.use(instrumentation: instrumentation) if instrumentation

            http.persistent(BASE_URL)
          end
      end

      def shutdown
        return unless pool?

        pool.shutdown { |conn| conn&.close }
      end

      def notification
        Expo::Push::Notification.new
      end

      private

      attr_accessor :access_token, :concurrency, :pool, :logger, :instrumentation

      def pool?
        !!pool
      end
    end
  end
end
