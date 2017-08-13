Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # create certificate, login, create user, admin listing, home page, user profile
  # later: create API user, view API user, admin listing of them
  get '/profile/<id>', to 'easyauth#profile'
  get '/admin', to 'easyauth#admin'
  get '/login', to 'easyauth#login'
  post '/login', to 'easyauth#do_login'
  get '/register', to 'easyauth#register'
  get '/create_cert', to 'easyauth#create_cert'
  root to 'easyauth#index'
end
