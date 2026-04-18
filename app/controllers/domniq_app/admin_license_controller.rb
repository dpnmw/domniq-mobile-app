# frozen_string_literal: true

module DomniqApp
  class AdminLicenseController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def status
      result = DomniqApp::LicenseChecker.check
      render json: license_json(result).merge(
        telemetry_enabled: SiteSetting.domniq_app_telemetry_enabled,
      )
    end

    def activate
      key = params.require(:license_key)
      result = DomniqApp::LicenseChecker.activate(key)

      if result["license_active"]
        render json: license_json(result)
      else
        render json: license_json(result).merge(error: result["error"] || "Invalid licence key."),
               status: :unprocessable_entity
      end
    end

    def check
      result = DomniqApp::LicenseChecker.check(force: true)
      render json: license_json(result)
    end

    def update_telemetry
      SiteSetting.domniq_app_telemetry_enabled =
        ActiveModel::Type::Boolean.new.cast(params[:telemetry_enabled])
      render json: success_json
    end

    private

    def license_json(result)
      json = {
        licensed: result["license_active"] == true,
        domain: result["domain"],
        email: result["email"],
        paid_at: result["paid_at"],
        expires_at: result["expires_at"],
        tier: result["tier"],
        last_checked: result["checked_at"],
        license_key: DomniqApp::LicenseChecker.license_key_masked,
      }
      json[:error] = result["error"] if result["error"].present?
      json
    end
  end
end
