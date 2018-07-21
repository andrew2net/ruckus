require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admins
  devise_for :accounts, controllers: {
    registrations: 'account/registrations',
    omniauth_callbacks: 'profile/omniauth_callbacks',
    sessions: 'account/sessions',
    passwords: 'account/passwords',
    invitations: 'account/invitations'
  }

  namespace :front do
    resources :profiles do
      resources :donations, only: [:new, :create]
      resources :events, only: [:index, :show]
      resources :press_releases, only: :index
      resources :issues, only: [:show, :index]
      resources :social_posts, only: [:index, :show]
      resources :questions, only: [:new, :create]
      resources :users, only: :create
    end

    get '/faq' => 'pages#faq'
    get '/contact_us' => 'pages#contact'
    get '/terms' => 'pages#terms'
    get '/how-to-update-domain' => 'pages#how_to_update_domain'
    resources :support_messages, only: [:create, :show]
    resource :score, only: [:create]
  end

  namespace :admin do
    authenticate :admin do
      mount Sidekiq::Web, at: '/sidekiq'
    end

    resources :accounts do
      resources :profiles do
        resources :updates, controller: 'press_releases', as: 'press_releases'
        resources :issues
      end
    end

    resources :payment_accounts, only: [:show, :edit, :update]

    resources :coupons do
      resource :sender_coupons, only: [:new, :create]
    end

    resources :profiles_stats, only: [:index]
    resources :domains
    resources :donations, only: [:index]
    resources :account_sessions, only: :show
    resources :pages, only: [:index, :edit, :update, :show]
    root 'accounts#index'
  end

  namespace :account do
    resources :sites, controller: 'profiles', as: 'profiles', only: [:index, :new, :create] do
      resources :accounts, only: [:index, :new, :create, :destroy] do
        resource :ownership, only: [:edit, :update]
      end

      resource :owner, only: [:update]

      resource :credit_card_holder, except: %i[index show] do # only: [:new, :create, :destroy, :edit] do
        get :cancel
      end
    end
    resource :profile, only: :update
  end

  namespace :profile do
    resources :domains
    resource :subdomain, only: [:edit, :show, :update]
    resources :donors, controller: 'donations', as: 'donations', only: :index
    resources :events, except: [:show]

    resources :updates, controller: 'press_releases', as: 'press_releases' do
      collection { post 'sort' }
    end

    resources :press_release_parsers, only: :create

    resource  :media_stream,     only: [:edit, :update, :create] { collection { patch 'sort' } }
    resources :media,            only: [:index, :destroy]
    resource  :photo,            only: [:edit, :update]
    resource  :background_image, only: [:edit, :update]
    resource  :hero_unit,        only: [:edit, :update]

    resources :issues, except: [:show] do
      collection do
        post 'sort'
      end
    end

    resources :issue_categories, only: :create
    resources :oauth_accounts,   only: [:index, :destroy]
    resources :social_posts, only: [:create, :new, :index, :destroy, :show]
    resource  :social,       only: [:edit, :update]
    resources :subscriptions, only: [:index]

    resource :payment_account, controller: :de_accounts,
                               as:         :de_account,
                               only:       [:new, :show, :create, :destroy]
    resource :builder_payment_account, only: [:show]

    resource :biography, only: [:edit, :update, :show]
    resource :page_option, only: [:edit, :update]
    resource :notification, only: [:edit, :update]
    resource :general_info, only: [:edit, :update]
    resource :dashboard, only: [:show]
    resource :builder, only: [:show, :update]
    resource :edit_map, only: [:show]
    resource :my_account,   only: [:edit]
    resource :dummy_destroy, only: [:destroy]
    resource :social, only: [:edit, :update]
    resource :help, only: [:show]
    resource :ip_update_help, only: [:show]
    resource :profile, only: [:update]
    resources :preview_profiles, only: [:show]

    root 'builders#show'
  end

  constraints(DomainMatcher) do
    get '/' => 'accounts#show'
  end

  root 'landing#index'
  get '/message' => 'landing#message'
end
