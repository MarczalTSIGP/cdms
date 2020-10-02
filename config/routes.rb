Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :audience_members, controllers: { registrations: 'audience_members/registrations' }
  authenticate :audience_member do
    namespace :audience_members do
      root to: 'dashboard#index'
    end
  end

  devise_for :admins
  authenticate :admin do
    namespace :admins do
      root to: 'dashboard#index'
      resources :users

      get '/administrators/search/(:term)', to: 'administrators#search_non_admins',
                                            as: 'search_non_administrators'
      resources :administrators, only: [:index, :create, :destroy]

      resources :audience_members
      get 'import_audience_members', to: 'audience_members#new_import', as: 'audience_members_import_new'
      post 'import_audience_members', to: 'audience_members#import', as: 'audience_members_import'

      resources :departments do
        resources :department_modules, except: [:index, :show], as: :modules, path: 'modules'

        get '/members', to: 'departments#members', as: :members
        get '/non-members/search/(:term)', costraints: { term: %r{[^/]+} }, # allows anything except a slash.
                                           to: 'departments#non_members',
                                           as: 'search_non_members'

        post '/members', to: 'departments#add_member', as: :add_member
        delete '/members/:id', to: 'departments#remove_member', as: 'remove_member'
      end
    end
  end

  as :admin do
    get 'admins/edit', to: 'admins/registrations#edit', as: 'edit_admin_registration'
    put 'admins/edit', to: 'admins/registrations#update', as: 'admin_registration'
  end
end
