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

      get 'documents/:id/signers', to: 'document_signers#signers', as: :document_signers
      patch 'documents/:id/sign', to: 'document_signers#sign', as: :sign_document

      get 'departments/:id/members', to: 'departments#members', as: :department_members

      post 'departments/:id/members', to: 'departments#add_member', as: :department_add_member
      delete 'departments/:department_id/members/:id', to: 'departments#remove_member',
                                                       as: :department_remove_member

      resources :documents, constraints: { id: /[0-9]+/ }, concerns: [:paginatable, :searchable_paginatable]
      post 'documents/:id/signers', to: 'document_signers#add_signer', as: :document_add_signer
      delete 'documents/:document_id/signers/:id', to: 'document_signers#remove_signer',
                                                   as: :document_remove_signer

      get 'documents/:id/preview', to: 'documents#preview', as: :preview_document
      get 'team-departments-modules', to: 'team_departments_modules#index', action: :index
      get 'show-department/:id', to: 'team_departments_modules#show_department',
                                 action: :show_department, as: :show_department

      get 'show-module/:id', to: 'team_departments_modules#show_module', action: :show_module, as: :show_module
      patch 'documents/:id/availability-to-sign', to: 'documents#toggle_available_to_sign',
                                                  as: :document_availability_to_sign

      get 'documents/:id/recipients', to: 'document_recipients#index',
                                      as: :document_recipients

      get 'documents/:id/recipients/from-csv/download-csv', to: 'document_recipients#download_csv', 
                                               as: :document_recipients_download_csv

      get 'documents/:id/recipients/from-csv', to: 'document_recipients#from_csv', 
                                               as: :new_document_recipients_from_csv
                                               
      post 'documents/:id/recipients/from-csv', to: 'document_recipients#create_from_csv', 
                                               as: :create_document_recipients_from_csv                                
                                               
      # get 'documents/:id/recipients/:id:variables', to: 'document_recipients#from_csv', 
      #                                         as: :show_document_recipients_
                                               
      get 'documents/:id/recipients/new', to: 'document_recipients#new',
                                          as: :new_recipient_document

      get 'documents/:id/non-recipient/search(/:cpf)', to: 'document_recipients#new',
                                                       as: :search_non_recipient,
                                                       constraints: { cpf: %r{[^/]+} }

      post 'documents/:id/recipients/:cpf', to: 'document_recipients#add_recipient',
                                            as: :document_add_recipient,
                                            constraints: { cpf: %r{[^/]+} }

      delete 'documents/:id/recipients/:cpf', to: 'document_recipients#remove_recipient',
                                              as: :document_remove_recipient,
                                              constraints: { cpf: %r{[^/]+} }

      patch 'documents/:id/reopen-to-edit', to: 'documents#reopen_to_edit',
                                            as: :reopen_document
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

        post '/modules/:id/members', to: 'department_modules#add_member', as: :module_add_member
        delete '/modules/:module_id/members/:id', to: 'department_modules#remove_member',
                                                  as: 'module_remove_member'
      end
    end
  end
end
