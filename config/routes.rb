Rails.application.routes.draw do
  post '/auth', to: 'authentications#login'
  put '/auth', to: 'authentications#refresh'

  resources :statistics, only: :index

  get '/applicants', to: 'applicants#show'
  resources :applicants, only: :index
  patch '/applicants', to: 'applicants#update'
end
