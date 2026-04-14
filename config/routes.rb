# frozen_string_literal: true

DomniqApp::Engine.routes.draw do
  # Public config API
  get "config" => "config#show"

  # Locales API
  get "locales" => "locales#index"
  get "locales/:locale" => "locales#show"
end

Discourse::Application.routes.draw do
  scope "/admin/plugins/domniq-mobile-app", constraints: AdminConstraint.new do
    # Admin page shells + file downloads (format: false)
    scope format: false do
      get "/overview" => "domniq_app/admin#index"
      get "/configuration" => "domniq_app/admin#index"
      get "/drawer" => "domniq_app/admin#index"
      get "/features" => "domniq_app/admin#index"
      get "/notifications" => "domniq_app/admin#index"
      get "/language" => "domniq_app/admin#index"
      get "/licensing" => "domniq_app/admin#index"
      get "/language/export" => "domniq_app/admin_language#export_defaults"
    end

    # Admin JSON API
    scope format: :json do
      # Configuration (branding, welcome, legal)
      get "/configs" => "domniq_app/admin_configuration#index"
      post "/configs" => "domniq_app/admin_configuration#create"
      put "/configs/:id" => "domniq_app/admin_configuration#update"
      delete "/configs/:id" => "domniq_app/admin_configuration#destroy"

      # Drawer
      get "/drawer/items" => "domniq_app/admin_drawer#index"
      post "/drawer/items" => "domniq_app/admin_drawer#create"
      put "/drawer/items/:id" => "domniq_app/admin_drawer#update"
      delete "/drawer/items/:id" => "domniq_app/admin_drawer#destroy"
      post "/drawer/reorder" => "domniq_app/admin_drawer#reorder"

      # Features
      get "/features/flags" => "domniq_app/admin_features#index"
      put "/features/flags" => "domniq_app/admin_features#update"

      # Language
      get "/language/locales" => "domniq_app/admin_language#index"
      post "/language/locales" => "domniq_app/admin_language#upload"
      delete "/language/locales/:id" => "domniq_app/admin_language#destroy"

      # Licensing
      get "/licensing/status" => "domniq_app/admin_licensing#status"
      post "/licensing/activate" => "domniq_app/admin_licensing#activate"
      post "/licensing/check" => "domniq_app/admin_licensing#check"
    end
  end
end
