# frozen_string_literal: true

module DomniqApp
  class AdminLanguageController < ::Admin::AdminController
    requires_plugin "domniq-mobile-app"

    def index
      brand_key = params[:brand] || "domniq"
      locales = LocaleFile.where(brand_key: brand_key).order(:locale)

      render json: {
        locales: locales.map { |l|
          {
            id: l.id,
            locale: l.locale,
            label: l.label,
            version: l.version,
            updated_at: l.updated_at,
          }
        },
      }
    end

    def upload
      brand_key = params[:brand] || "domniq"
      locale = params.require(:locale)
      label = params.require(:label)
      po_data = params.require(:po_file).read

      locale_file = LocaleFile.find_or_initialize_by(brand_key: brand_key, locale: locale)
      locale_file.label = label
      locale_file.po_data = po_data
      locale_file.version = (locale_file.version || 0) + 1
      locale_file.save!

      render json: {
        locale: {
          id: locale_file.id,
          locale: locale_file.locale,
          label: locale_file.label,
          version: locale_file.version,
          updated_at: locale_file.updated_at,
        },
      }
    end

    def destroy
      locale_file = LocaleFile.find(params[:id])
      locale_file.destroy!

      render json: success_json
    end

    def export_defaults
      # Generate a PO file from the branding.ts defaults
      # This would be populated from a seeded config or provided by the app
      po_content = DomniqApp::PoParser.generate_default_po

      send_data po_content,
        filename: "domniq-defaults-en.po",
        type: "text/plain",
        disposition: "attachment"
    end
  end
end
