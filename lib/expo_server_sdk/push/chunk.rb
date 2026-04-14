# frozen_string_literal: true

module Expo
  module Push
    class Chunk
      def self.for(notifications)
        Array(notifications).each_with_object([]) do |notification, chunks|
          chunk = chunks.last || Chunk.new.tap { |c| chunks << c }

          targets = notification.recipients.dup

          while targets.length.positive?
            chunk = Chunk.new.tap { |c| chunks << c } if chunk.remaining <= 0

            count = [targets.length, chunk.remaining].min
            chunk_targets = targets.slice(0, count)

            chunk << notification.prepare(chunk_targets)

            targets = targets.drop(count)
          end
        end
      end

      attr_reader :remaining

      def initialize
        self.notifications = []
        self.remaining = PUSH_NOTIFICATION_CHUNK_LIMIT
      end

      def <<(notification)
        self.remaining -= notification.count
        notifications << notification

        self
      end

      def count
        notifications.sum(&:count)
      end

      def as_json
        notifications.map(&:as_json)
      end

      def all_recipients
        notifications.flat_map(&:recipients)
      end

      private

      attr_accessor :notifications
      attr_writer :remaining
    end
  end
end
