# frozen_string_literal: true

module DomniqApp
  class PoParser
    def self.generate_default_po
      header = <<~PO
        # Domniq Mobile App - English Defaults
        # Generated from branding.ts
        #
        msgid ""
        msgstr ""
        "Content-Type: text/plain; charset=UTF-8\\n"
        "Language: en\\n"

      PO

      # Default strings that match branding.ts keys
      # These will be populated from the app's branding config
      defaults = PluginStore.get("domniq_app", "default_strings") || {}

      entries = defaults.map do |key, value|
        escaped_value = value.to_s.gsub('"', '\\"')
        "msgid \"#{key}\"\nmsgstr \"#{escaped_value}\"\n"
      end

      header + entries.join("\n")
    end

    def self.parse(po_content)
      strings = {}
      current_msgid = nil

      po_content.each_line do |line|
        line = line.strip

        if line.start_with?("msgid ")
          current_msgid = extract_string(line.sub("msgid ", ""))
        elsif line.start_with?("msgstr ") && current_msgid && current_msgid != ""
          msgstr = extract_string(line.sub("msgstr ", ""))
          strings[current_msgid] = msgstr if msgstr.present?
          current_msgid = nil
        end
      end

      strings
    end

    def self.extract_string(quoted)
      quoted.strip.gsub(/\A"|"\z/, "").gsub('\\"', '"').gsub("\\n", "\n")
    end
  end
end
