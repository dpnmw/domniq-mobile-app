# frozen_string_literal: true

module DomniqApp
  class ExpoSubscription < ActiveRecord::Base
    self.table_name = "domniq_app_expo_subscriptions"

    belongs_to :user
    belongs_to :user_auth_token, optional: true

    validates :expo_pn_token, presence: true, uniqueness: true
    validates :platform, presence: true, inclusion: { in: %w[ios android] }
    validates :application_name, presence: true
    # experience_id is intentionally not validated for presence —
    # Expo SDK 54 apps may omit it; default is empty string in the DB.
  end
end
