# frozen_string_literal: true

module DomniqApp
  class LocalesController < ::ApplicationController
    requires_plugin ::DomniqApp::PLUGIN_NAME

    skip_before_action :check_xhr
    skip_before_action :verify_authenticity_token

    def index
      brand_key = params[:brand] || "domniq"

      locales = LocaleFile.where(brand_key: brand_key).select(:id, :locale, :label, :version, :updated_at)

      render json: {
        locales: locales.map { |l|
          { locale: l.locale, label: l.label, version: l.version, updated_at: l.updated_at }
        },
      }
    end

    def show
      brand_key = params[:brand] || "domniq"
      locale = params[:locale].sub(/\.po\z/, "")

      locale_file = LocaleFile.find_by(brand_key: brand_key, locale: locale)
      unless locale_file
        raise Discourse::NotFound.new(I18n.t("domniq_app.errors.locale_not_found"))
      end

      etag = "\"#{brand_key}-#{locale}-v#{locale_file.version}\""

      if stale?(etag: etag, public: true)
        response.headers["Cache-Control"] = "public, max-age=300"
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        render plain: locale_file.po_data
      end
    end
  end
end
