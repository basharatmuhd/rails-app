Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  mount StripeEvent::Engine, at: '/stripe_hook'

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :user do
    devise_for :users
  end

  get 'hyperlect_app', to: 'pages#hyperlect_app'
  get 'stripe_connect_redirect', to: 'pages#stripe_connect_redirect'
  get 'websockets/test', to: 'pages#test'
  get :api, to: 'api/pages#doc'
  root to: 'pages#home'

  namespace :api, defaults: { format: :json } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      post :sign_in, to: "user_token#create"
      delete :sign_out, to: "sessions#sign_out"

      get :s3_access, to: "upload#s3_access"

      post 'payments/add_customer', to: 'payments#add_customer'
      post 'payments/add_card', to: 'payments#add_card'
      post 'payments/delete_card', to: 'payments#delete_card'
      post 'payments/charge', to: 'payments#charge'
      post 'payments/release_funds', to: 'payments#release_funds'

      get 'payments/customer_sources', to: 'payments#customer_sources'
      get 'activities', to: 'activities#index'

      resources :users, only: [:create] do
        collection do
          put :update_profile, :update_push_token
        end
      end
      resource :password, only: [:create, :update], controller: :passwords

      resources :contacts, only: [:create]

      resources :projects, only: [:index, :create, :show, :update, :destroy] do
        collection do
          get :recap
        end
      end

      resources :milestones, only: [:update, :destroy] do
        member do
          put :mark_as_completed, :mark_as_uncompleted, :add_images
        end
      end

      resources :merchants, only: [:create] do
        collection do
          get :authorize_url, :stripe_account
          put :deauthorize
        end
      end

      resources :messages, only: [:create, :index] do
        collection do
          get :inbox
          post :mark_all_as_read
        end
      end
      resources :charges, only: [:index]
    end
  end
end
