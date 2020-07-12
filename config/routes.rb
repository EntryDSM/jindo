Rails.application.routes.draw do
  scope(path: '/v5/admin') do
    post '/auth', to: 'authentications#login'
    put '/auth', to: 'authentications#refresh'

    resources :statistics, only: :index

    get '/applicant', to: 'applicants#show'
    get '/applicants', to: 'applicants#index'
    patch '/applicant', to: 'applicants#update'
    post '/applicants', to: 'applicants#create'
  end
end
