# frozen_string_literal: true

module DomniqApp
  class ConfigBuilder
    def self.build(brand_key)
      configs = AppConfig.where(brand_key: brand_key, enabled: true)

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
          next if !licensed && merged[:category] && LicenseChecker.drawer_category_locked?(merged[:category])

          # The home-screen Leaderboard Stories row is all-or-nothing: admin-off
          # means don't ship it at all (it's a home-page teaser, no point
          # teasing a locked item). Other drawer items stay in the payload with
          # a `disabled_reason` so the app can render a locked tile.
          feature_key = merged[:featureKey] || merged["featureKey"]
          forum_available = ForumFeatures.available?(feature_key)
          admin_enabled = config.enabled

          if config.config_key == "leaderboard_stories"
            next unless admin_enabled && forum_available
          end

          # Compute effective state. `enabled: false` + `disabled_reason` lets
          # the app pick between "Disabled by Forum" and "Feature Not Available"
          # locked-state messages.
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
