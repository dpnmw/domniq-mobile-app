# frozen_string_literal: true

module DomniqApp
  # Detects which optional Discourse features are installed & enabled on this
  # forum. Used to tell the mobile app which drawer items are "not available"
  # on this forum vs. "admin-disabled via the plugin."
  #
  # Each feature key tries a list of candidate SiteSetting names in order —
  # different Discourse versions and plugin revs have used different names
  # (e.g. the Gamification plugin has shipped as both `gamification_enabled`
  # and `discourse_gamification_enabled`). We also check whether the plugin
  # is loaded at all via `Discourse.plugins`, since an uninstalled plugin
  # should count as "not available" even if a stale SiteSetting row exists.
  class ForumFeatures
    # featureKey -> { candidate setting names, plugin_name (optional) }
    FEATURE_RESOLVERS = {
      "gamification" => {
        settings: %i[discourse_gamification_enabled gamification_enabled],
        plugin: "discourse-gamification",
      },
      "groups" => {
        # Core Discourse — no plugin check needed.
        settings: %i[enable_group_directory],
      },
    }.freeze

    def self.available?(feature_key)
      return true if feature_key.nil? || feature_key.to_s.empty?
      resolver = FEATURE_RESOLVERS[feature_key.to_s]
      return true unless resolver

      # If a specific plugin is required, confirm it's actually loaded.
      if resolver[:plugin] && !plugin_loaded?(resolver[:plugin])
        return false
      end

      # Try each candidate setting; first one that exists wins.
      resolver[:settings].each do |setting|
        next unless SiteSetting.respond_to?(setting)
        return !!SiteSetting.public_send(setting)
      end

      # No known setting exists for this feature — if the plugin is loaded
      # (or none was required), assume available. If the plugin was required
      # we'd have returned false above already.
      true
    end

    def self.snapshot
      FEATURE_RESOLVERS.keys.each_with_object({}) do |key, h|
        h[key] = available?(key)
      end
    end

    def self.plugin_loaded?(plugin_name)
      Discourse.plugins.any? { |p| p.name == plugin_name && p.enabled? }
    rescue StandardError
      # Defensive: older Discourse Plugin API versions may not have `.enabled?`
      Discourse.plugins.any? { |p| p.name == plugin_name }
    end
  end
end
