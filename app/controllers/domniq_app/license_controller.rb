# frozen_string_literal: true

module DomniqApp
  # Public-facing license status endpoint for the mobile app.
  #
  # Returns only the subset of licensing info the app needs to make UI
  # decisions. Does NOT expose license_key, email, paid_at, or admin-only
  # fields — those remain behind AdminLicenseController.
  #
  # `expires_at` is intentionally exposed (ISO-8601 UTC) so the trial UI can
  # render precise countdowns (e.g. "2 days, 14 hours left").
  class LicenseController < ::ApplicationController
    requires_plugin ::DomniqApp::PLUGIN_NAME

    def status
      result = DomniqApp::LicenseChecker.check
      active = result && result["license_active"] == true

      payload = { active: active }

      if active
        payload[:tier] = result["tier"] if result["tier"]
        days = days_remaining(result["expires_at"])
        payload[:days_remaining] = days unless days.nil?
        payload[:expires_at] = iso8601(result["expires_at"]) if result["expires_at"]
      end

      response.headers["Cache-Control"] = "no-store"
      render json: payload
    end

    private

    def days_remaining(expires_at)
      return nil if expires_at.blank?
      expiry = Time.parse(expires_at.to_s)
      diff = ((expiry - Time.now) / 86_400).ceil
      [diff, 0].max
    rescue ArgumentError, TypeError
      nil
    end

    def iso8601(expires_at)
      Time.parse(expires_at.to_s).utc.iso8601
    rescue ArgumentError, TypeError
      nil
    end
  end
end
