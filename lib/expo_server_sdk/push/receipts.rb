# frozen_string_literal: true

module Expo
  module Push
    class Receipt
      attr_reader :data, :receipt_id

      def initialize(data:, receipt_id:)
        self.data = data
        self.receipt_id = receipt_id
      end

      def original_push_token
        return nil if ok?

        if message.include?("PushToken[")
          return /Expo(?:nent)?PushToken\[(?:[^\]]+?)\]/.match(message) { |match| match[0] }
        end

        /\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\z/i.match(message) { |match| match[0] }
      end

      def message
        data.fetch("message")
      end

      def error_message
        data.fetch("details").fetch("error")
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

      attr_writer :data, :receipt_id
    end

    class Receipts
      def initialize(results:, requested_ids:)
        self.results = results
        self.requested_ids = requested_ids
      end

      def each
        results.each do |receipt|
          next unless receipt.ok?

          yield receipt
        end
      end

      def each_error
        results.each do |receipt|
          next yield receipt if receipt.is_a?(Error)
          next unless receipt.error?

          yield receipt
        end
      end

      def unresolved_ids
        requested_ids - results.map(&:receipt_id)
      end

      private

      attr_accessor :results, :requested_ids
    end
  end
end
