# frozen_string_literal: true

module Expo
  module Push
    class Notification
      attr_accessor :recipients

      def self.to(recipient)
        new.to(recipient)
      end

      def initialize(_recipient = [])
        self.recipients = []
        self._params = {}
      end

      def to(recipient_or_multiple)
        Array(recipient_or_multiple).each do |recipient|
          self << recipient
        end

        self
      rescue NoMethodError
        raise ArgumentError, "to must be a single Expo Push Token, or an array-like/enumerator of Expo Push Tokens"
      end

      def data(value)
        json_data = value.respond_to?(:as_json) ? value.as_json : value.to_h

        raise ArgumentError, "data must be hash-like or nil" if !json_data.nil? && !json_data.is_a?(Hash)

        _params[:data] = json_data
        self
      rescue NoMethodError
        raise ArgumentError, "data must be hash-like, respond to as_json, or nil"
      end

      def title(value)
        _params[:title] = value.nil? ? nil : String(value)
        self
      rescue NoMethodError
        raise ArgumentError, "title must be nil or string-like"
      end

      def subtitle(value)
        _params[:subtitle] = value.nil? ? nil : String(value)
        self
      rescue NoMethodError
        raise ArgumentError, "subtitle must be nil or string-like"
      end

      alias sub_title subtitle

      def body(value)
        _params[:body] = value.nil? ? nil : String(value)
        self
      rescue NoMethodError
        raise ArgumentError, "body must be nil or string-like"
      end

      alias content body

      def sound(value)
        if value.nil?
          _params[:sound] = nil
          return self
        end

        unless value.respond_to?(:to_h)
          _params[:sound] = String(value)
          return self
        end

        json_value = value.to_h

        next_value = {
          critical: !json_value.fetch(:critical, nil).nil?,
          name: json_value.fetch(:name, nil),
          volume: json_value.fetch(:volume, nil),
        }

        next_value[:name] = String(next_value[:name]) unless next_value[:name].nil?
        next_value[:volume] = next_value[:volume].to_i unless next_value[:volume].nil?

        _params[:sound] = next_value.compact

        self
      end

      def ttl(value)
        _params[:ttl] = value.nil? ? nil : value.to_i
        self
      rescue NoMethodError
        raise ArgumentError, "ttl must be numeric or nil"
      end

      def expiration(value)
        _params[:expiration] = value.nil? ? nil : value.to_i
        self
      rescue NoMethodError
        raise ArgumentError, "expiration must be numeric or nil"
      end

      def priority(value)
        if value.nil?
          _params[:priority] = nil
          return self
        end

        priority_string = String(value)

        unless %w[default normal high].include?(priority_string)
          raise ArgumentError, "priority must be default, normal, or high"
        end

        _params[:priority] = priority_string
        self
      rescue NoMethodError
        raise ArgumentError, "priority must be default, normal, or high"
      end

      def badge(value)
        _params[:badge] = value.nil? ? nil : value.to_i
        self
      rescue NoMethodError
        raise ArgumentError, "badge must be numeric or nil"
      end

      def channel_id(value)
        _params[:channelId] = value.nil? ? nil : String(value)
        self
      rescue NoMethodError
        raise ArgumentError, "channelId must be string-like or nil"
      end

      alias channel_identifier channel_id

      def category_id(value)
        _params[:categoryId] = value.nil? ? nil : String(value)
        self
      rescue NoMethodError
        raise ArgumentError, "categoryId must be string-like or nil"
      end

      def mutable_content(value)
        _params[:mutableContent] = value.nil? ? nil : !value.nil?
        self
      end

      alias mutable mutable_content

      def <<(recipient)
        raise PushTokenInvalid.new(token: recipient) unless Expo::Push.expo_push_token?(recipient)

        recipients << recipient

        self
      end

      alias add_recipient <<
      alias add_recipients to

      def prepare(targets)
        dup.tap { |prepared| prepared.reset_recipients(targets) }
      end

      def count
        recipients.length
      end

      def as_json
        { to: recipients }.merge(_params.compact)
      end

      def reset_recipients(targets)
        self.recipients = []
        add_recipients(targets)
      end

      private

      attr_accessor :_params
    end
  end
end
