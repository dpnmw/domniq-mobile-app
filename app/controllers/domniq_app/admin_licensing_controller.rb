# frozen_string_literal: true

module DomniqApp
  class AdminLicensingController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def status
      render json: {
        licensed: DomniqApp::LicenseChecker.licensed?,
        license_key: DomniqApp::LicenseChecker.license_key_masked,
        expires_at: DomniqApp::LicenseChecker.expires_at,
        telemetry_enabled: SiteSetting.domniq_app_telemetry_enabled,
      }
    end

    def activate
      license_key = params.require(:license_key)
      result = DomniqApp::LicenseChecker.activate(license_key)

      if result[:success]
        render json: { licensed: true, message: "License activated successfully." }
      else
        render json: { licensed: false, error: result[:error] }, status: :unprocessable_entity
      end
    end

    def check
      result = DomniqApp::LicenseChecker.check
      render json: result
    end

    def update_telemetry
      SiteSetting.domniq_app_telemetry_enabled =
        ActiveModel::Type::Boolean.new.cast(params[:telemetry_enabled])
      render json: success_json
    end
  end
end
