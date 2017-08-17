Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # create certificate, login, create user, admin listing, home page, user profile
  # later: create API user, view API user, admin listing of them
  get '/profile/:id', to: 'easyauth#profile'
  post '/profile/:id', to: 'easyauth#do_profile'
  get '/api_profile/:id', to: 'easyauth#view_api_key_user'
  get '/admin', to: 'easyauth#admin'
  post '/admin', to: 'easyauth#do_admin'
  get '/login', to: 'easyauth#login'
  post '/login', to: 'easyauth#do_login'
  get '/api_login', to: 'easyauth#api_login'
  post '/api_login', to: 'easyauth#do_api_login'
  get '/logout', to: 'easyauth#logout'
  get '/register', to: 'easyauth#register'
  post '/register', to: 'easyauth#do_register'
  get '/api_register', to: 'easyauth#apikey'
  post '/api_register', to: 'easyauth#do_apikey'
  get '/validate', to: 'easyauth#validate'
  post '/validate', to: 'easyauth#do_validate'
  get '/validate_api', to: 'easyauth#validate_api'
  post '/validate_api', to: 'easyauth#do_validate_api'
  get '/create_cert', to: 'easyauth#create_cert'
  post '/create_cert', to: 'easyauth#do_create_cert'
  get '/delete_certificate/:id', to: 'easyauth#delete_certificate'
  post '/delete_certificate/:id', to: 'easyauth#do_delete_certificate'
  get '/revoke_certificate/:id', to: 'easyauth#revoke_certificate'
  post '/revoke_certificate/:id', to: 'easyauth#do_revoke_certificate'
  get '/delete_user/:id', to: 'easyauth#delete_user'
  post '/delete_user/:id', to: 'easyauth#do_delete_user'

  root to: 'easyauth#index'
end
