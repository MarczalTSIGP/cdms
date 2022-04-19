Rails.application.routes.draw do
  root to: 'home#index'
  get '/about', to: 'home#about'
  get '/login', to: 'home#login'

  devise_for :users
  as :user do
    get 'users/edit', to: 'users/registrations#edit', as: 'edit_user_registration'
    put 'users/edit', to: 'users/registrations#update', as: 'user_registration'
  end

  authenticate :user do
    namespace :api do
      get ':model_name/:id/non-members/search/(:term)',
          costraints: { term: %r{[^/]+} }, # allows anything except a slash.
          to: 'search_members#search_non_members',
          as: 'search_non_members'
    end

    namespace :users do
      concern :paginatable do
        get '(page/:page)', action: :index, on: :collection, as: ''
      end
      concern :searchable_paginatable do
        get '/search/(:term)/(page/:page)', action: :index, on: :collection, as: :search
      end

      root to: 'dashboard#index'

      get 'documents/:id/members', to: 'documents#members', as: :document_members

      get 'departments/:id/members', to: 'departments#members', as: :department_members

      post 'departments/:id/members', to: 'departments#add_member', as: :department_add_member
      delete 'departments/:department_id/members/:id', to: 'departments#remove_member',
                                                       as: :department_remove_member

      resources :documents, concerns: [:paginatable, :searchable_paginatable]
      post 'documents/:id/members', to: 'documents#add_member', as: :document_add_member
      delete 'documents/:document_id/members/:id', to: 'documents#remove_member',
                                                   as: :document_remove_member
      get '(:document_id)/(:user_id)/non-members/search/(:term)',
          to: 'documents#search_non_members_document',
          as: 'search_non_members_documents'

      get 'documents/:id/preview', to: 'documents#preview', as: :preview_document
      get 'team-departments-modules', to: 'team_departments_modules#index', action: :index
      get 'show-department/:id', to: 'team_departments_modules#show_department',
                                 action: :show_department, as: :show_department

      get 'show-module/:id', to: 'team_departments_modules#show_module', action: :show_module, as: :show_module
      patch 'documents/:id/availability-to-sign', to: 'documents#toggle_available_to_sign',
                                                  as: :document_availability_to_sign
    end

    namespace :admins do
      root to: 'dashboard#index'

      get 'edit_about_page', to: 'pages#edit'
      post 'edit_about_page', to: 'pages#update'

      concern :paginatable do
        get '(page/:page)', action: :index, on: :collection, as: ''
      end
      concern :searchable_paginatable do
        get '/search/(:term)/(page/:page)', action: :index, on: :collection, as: :search
      end

      resources :users, constraints: { id: /[0-9]+/ }, concerns: [:paginatable, :searchable_paginatable]
      resources :administrators, only: [:index, :create, :destroy]
      resources :document_roles, concerns: [:paginatable, :searchable_paginatable]
      get '/administrators/search/(:term)', to: 'administrators#search_non_admins',
                                            as: 'search_non_administrators'

      resources :audience_members, constraints: { id: /[0-9]+/ }, concerns: [:paginatable, :searchable_paginatable]
      get 'audience_members/from-csv', to: 'audience_members#from_csv', as: :new_audience_members_from_csv
      post 'audience_members/from-csv', to: 'audience_members#create_from_csv', as: :create_audience_members_from_csv

      resources :departments, constraints: { id: /[0-9]+/ }, concerns: [:paginatable, :searchable_paginatable] do
        resources :department_modules, except: [:index, :show], as: :modules, path: 'modules'

        get '/members', to: 'departments#members', as: :members

        post '/members', to: 'departments#add_member', as: :add_member
        delete '/members/:id', to: 'departments#remove_member', as: 'remove_member'

        get '/modules/:id/members', to: 'department_modules#members', as: :module_members

        post '/modules/:id/members', to: 'department_modules#add_module_member', as: :module_add_member
        delete '/modules/:module_id/members/:id', to: 'department_modules#remove_module_member',
                                                  as: 'module_remove_member'
      end
    end
  end
end
