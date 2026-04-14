# frozen_string_literal: true

module DomniqApp
  class LocaleFile < ActiveRecord::Base
    self.table_name = "#{DomniqApp.table_name_prefix}locale_files"

    validates :brand_key, presence: true
    validates :locale, presence: true
    validates :label, presence: true
    validates :po_data, presence: true
    validates :locale, uniqueness: { scope: :brand_key }
  end
end
