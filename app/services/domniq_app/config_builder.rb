# frozen_string_literal: true

module DomniqApp
  class ConfigBuilder
    def self.build(brand_key)
      configs = AppConfig.where(brand_key: brand_key, enabled: true)

      version = PluginStore.get("domniq_app", "config_version:#{brand_key}") || 0

      result = {
        version: version,
        generated_at: Time.current.iso8601,
        brand: brand_key,
        branding: {},
        feature_flags: {},
        drawer: [],
        welcome: {},
        legal: {},
      }

      configs.order(:config_type, :position).each do |config|
        value = parse_value(config.config_value)

        case config.config_type
        when "branding"
          result[:branding][config.config_key] = value
        when "feature_flags"
          result[:feature_flags][config.config_key] = value
        when "drawer"
          result[:drawer] << { key: config.config_key, position: config.position }.merge(value.is_a?(Hash) ? value : { value: value })
        when "welcome"
          result[:welcome][config.config_key] = value
        when "legal"
          result[:legal][config.config_key] = value
        end
      end

      result
    end

    def self.parse_value(value)
      JSON.parse(value)
    rescue JSON::ParserError
      value
    end
  end
end
