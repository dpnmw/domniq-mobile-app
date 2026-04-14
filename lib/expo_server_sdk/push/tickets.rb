# frozen_string_literal: true

module Expo
  module Push
    class Ticket
      attr_reader :data, :token

      def initialize(data, token)
        self.data = data
        self.token = token
      end

      def id
        data.fetch("id")
      end

      def original_push_token
        token
      end

      def message
        data.fetch("message")
      end

      def explain
        Expo::Push::Error.explain((data["details"] || {})["error"])
      end

      def ok?
        data["status"] == "ok"
      end

      def error?
        data["status"] == "error"
      end

      private

      attr_writer :data, :token
    end

    class Tickets
      def initialize(results)
        self.results = results
      end

      def ids
        [].tap { |ids| each { |ticket| ids << ticket.id } }
      end

      def token_by_receipt_id
        {}.tap { |hash| each { |ticket| hash[ticket.id] = ticket.original_push_token } }
      end

      def batch_ids
        ids.each_slice(PUSH_NOTIFICATION_RECEIPT_CHUNK_LIMIT).to_a
      end

      def each
        results.each do |tickets|
          next if tickets.is_a?(Error)

          tickets.each do |ticket|
            next unless ticket.ok?

            yield ticket
          end
        end
      end

      def each_error
        results.each do |tickets|
          if tickets.is_a?(Error)
            yield tickets
          else
            tickets.each do |ticket|
              next unless ticket.error?

              yield ticket
            end
          end
        end
      end

      private

      attr_accessor :results
    end
  end
end
