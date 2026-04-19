# frozen_string_literal: true

module DomniqApp
  class ConfigBuilder
    def self.build(brand_key)
      # The `enabled` column is only meaningful for drawer rows (where it drives
      # the admin "Disabled by Forum" locked-tile state). For every other config
      # type (branding, feature_flags, welcome, legal), `enabled` is ignored:
      # those rows are either present (and shown) or deleted. Admin UIs for
      # those types don't expose an enabled toggle, so every row has
      # `enabled: true` in practice. If a future admin UI ever surfaces an
      # enabled toggle for non-drawer rows, revisit this — it will silently
      # re-surface rows they expected to hide.
      configs = AppConfig.where(brand_key: brand_key)

      version = PluginStore.get("domniq_app", "config_version:#{brand_key}") || 0
      licensed = LicenseChecker.licensed?

      result = {
        version: version,
        generated_at: Time.current.iso8601,
        brand: brand_key,
        licensed: licensed,
        branding: {},
        feature_flags: {},
        drawer: [],
        welcome: {},
        legal: {},
      }

      configs.order(:config_type, :position).each do |config|
        # Skip anything locked when the forum isn't licensed. Paid white-label
        # clients whose license lapses keep their free content (app_name,
        # legal URLs, Community/Settings/Support drawer items, etc.) — only
        # premium sections disappear from the response.
        next if !licensed && locked_config?(config)

        value = parse_value(config.config_value)

        case config.config_type
        when "branding"
          result[:branding][config.config_key] = value
        when "feature_flags"
          result[:feature_flags][config.config_key] = value
        when "drawer"
          merged = { key: config.config_key, position: config.position }
            .merge(value.is_a?(Hash) ? value : { value: value })
          # Drop drawer items whose category is locked (Premium, Admin Dashboard).
          # License gating is authoritative for those categories — the app
          # doesn't even see them when the forum's license is inactive.
          next if !licensed && merged[:category] && LicenseChecker.drawer_category_locked?(merged[:category])

          # Admin-controlled lock state applies only to Community items that
          # gate on a native forum feature (Leaderboard, Groups). Other items
          # always ship with enabled:true — admin has no toggle for them.
          feature_key = merged[:featureKey] || merged["featureKey"]
          forum_available = ForumFeatures.available?(feature_key)
          admin_enabled = config.enabled

          if !forum_available
            merged[:enabled] = false
            merged[:disabled_reason] = "not_installed"
          elsif !admin_enabled
            merged[:enabled] = false
            merged[:disabled_reason] = "admin_locked"
          else
            merged[:enabled] = true
          end

          result[:drawer] << merged
        when "welcome"
          result[:welcome][config.config_key] = value
        when "legal"
          result[:legal][config.config_key] = value
        end
      end

      result
    end

    def self.locked_config?(config)
      LicenseChecker.section_fully_locked?(config.config_type) ||
        LicenseChecker.config_locked?(config.config_type, config.config_key)
    end

    def self.parse_value(value)
      JSON.parse(value)
    rescue JSON::ParserError
      value
    end
  end
end
