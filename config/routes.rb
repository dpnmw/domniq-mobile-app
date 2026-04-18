# frozen_string_literal: true

DomniqApp::Engine.routes.draw do
  # Public config API
  get "config" => "config#show"

  # Locales API
  get "locales" => "locales#index"
  get "locales/:locale" => "locales#show"

  # Push notification token registration (requires authentication)
  post "push/subscribe"   => "push#subscribe"
  post "push/unsubscribe" => "push#unsubscribe"
end

Discourse::Application.routes.draw do
  scope "/admin/plugins/domniq-mobile-app", constraints: AdminConstraint.new do
    # Admin page shells + file downloads (format: false)
    scope format: false do
      get "/dma-overview" => "domniq_app/admin#index"
      get "/dma-configuration" => "domniq_app/admin#index"
      get "/dma-drawer" => "domniq_app/admin#index"
      get "/dma-features" => "domniq_app/admin#index"
      get "/dma-notifications" => "domniq_app/admin#index"
      get "/dma-language" => "domniq_app/admin#index"
      get "/dma-premium" => "domniq_app/admin#index"
      get "/language/export" => "domniq_app/admin_language#export_defaults"
    end

    # Admin JSON API
    scope format: :json do
      # Configuration (branding, welcome, legal)
      get "/configs" => "domniq_app/admin_configuration#index"
      post "/configs" => "domniq_app/admin_configuration#create"
      put "/configs/bulk" => "domniq_app/admin_configuration#bulk_update"
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

      # Notifications
      get "/notifications/settings" => "domniq_app/admin_notifications#settings"
      put "/notifications/settings" => "domniq_app/admin_notifications#update_settings"
      delete "/notifications/subscriptions/:id" => "domniq_app/admin_notifications#remove_subscription"
      post   "/notifications/test"              => "domniq_app/admin_notifications#test_push"
      get  "/notifications/search"  => "domniq_app/admin_notifications#search"
      post "/notifications/cleanup" => "domniq_app/admin_notifications#cleanup"

      # Language
      get "/language/locales" => "domniq_app/admin_language#index"
      post "/language/locales" => "domniq_app/admin_language#upload"
      delete "/language/locales/:id" => "domniq_app/admin_language#destroy"

      # Licensing
      get  "/license/status"    => "domniq_app/admin_license#status"
      post "/license/activate"  => "domniq_app/admin_license#activate"
      post "/license/check"     => "domniq_app/admin_license#check"
      put  "/license/telemetry" => "domniq_app/admin_license#update_telemetry"
    end
  end
end
