# frozen_string_literal: true

module DomniqApp
  class ExpoSubscription < ActiveRecord::Base
    self.table_name = "#{DomniqApp.table_name_prefix}expo_subscriptions"

    belongs_to :user
    belongs_to :user_auth_token
  end
end
