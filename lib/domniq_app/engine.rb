# frozen_string_literal: true

module DomniqApp
  class Engine < ::Rails::Engine
    isolate_namespace DomniqApp
    engine_name PLUGIN_NAME
  end
end
