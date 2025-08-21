# plugins/cloudogu_patches/config/routes.rb

# Allow both front-channel (GET) and back-channel (POST)
RedmineApp::Application.routes.draw do
  match 'account/cas', to: 'account#cas', via: [:get, :post]
end

