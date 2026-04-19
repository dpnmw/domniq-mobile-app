# frozen_string_literal: true

module DomniqApp
  # Detects which optional Discourse features are installed & enabled on this
  # forum. Used to tell the mobile app which drawer items are "not available"
  # on this forum vs. "admin-disabled via the plugin."
  #
  # Both settings below are part of core Discourse — no `respond_to?` guards.
  class ForumFeatures
    # Maps each drawer item's `featureKey` (in its config_value JSON) to the
    # core SiteSetting that determines availability. Items without a featureKey
    # are always available from the forum's perspective.
    FEATURE_KEY_SITE_SETTINGS = {
      "gamification" => :discourse_gamification_enabled,
      "groups"       => :enable_group_directory,
    }.freeze

    # True when the forum supports the given featureKey. Unknown keys return
    # true (no gating) — the plugin shouldn't fight the app over items it
    # doesn't know how to check.
    def self.available?(feature_key)
      return true if feature_key.nil? || feature_key.to_s.empty?
      setting = FEATURE_KEY_SITE_SETTINGS[feature_key.to_s]
      return true unless setting
      !!SiteSetting.public_send(setting)
    end

    # Snapshot of every known feature's availability. Rendered in the admin
    # drawer editor so toggle rows show "Gamification Enabled/Disabled" next
    # to the items that depend on those features.
    def self.snapshot
      FEATURE_KEY_SITE_SETTINGS.keys.each_with_object({}) do |key, h|
        h[key] = available?(key)
      end
    end
  end
end
