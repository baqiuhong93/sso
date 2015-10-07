OauthProviderDemo::Application.routes.draw do
  
  captcha_route
  
  devise_for :users, :controllers => { :registrations => 'registrations',
                                       :sessions => 'sessions'}
  # omniauth client stuff
  match '/auth/:provider/callback', :to => 'authentications#create'
  match '/auth/failure', :to => 'authentications#failure'

  # Provider stuff
  match '/auth/josh_id/authorize' => 'auth#authorize'
  match '/auth/josh_id/access_token' => 'auth#access_token'
  match '/auth/josh_id/user' => 'auth#user'
  match '/oauth/token' => 'auth#access_token'

  # Account linking
  match 'authentications/:user_id/link' => 'authentications#link', :as => :link_accounts
  match 'authentications/:user_id/add' => 'authentications#add', :as => :add_account

  root :to => 'auth#welcome'
  
  match 'update_email' => 'users#update_email', :as => :update_email
  match 'update_password' => 'users#update_password', :as => :update_password
  match 'users/status' => 'users#status', :as => :users_status
end
