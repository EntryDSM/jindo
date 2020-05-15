Rails.application.routes.draw do
  post '/auth', to: 'authentications#login'
  put '/auth', to: 'authentications#refresh'

  resources :statistics, only: :index
  resources :applicants, only: %i[show index update], param: :email
end
