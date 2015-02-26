Rails.application.routes.draw do
  resources :organisations do
    collection do
      get :invite
      get :users
      delete :remove_user
    end
    put :save_current_organisation#, :on => :collection

    get :autocomplete_user_email, :on => :collection
  end

  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :users

  resources :documents do
    collection do
      put :save_role_response, as: :save_role_response
    end
  end

  get 'documents/dashboard'
  match 'documents', to: 'documents#handle_status', via: :put, as: :handle_status

  resources :document_types
  match '/document_types', to: 'document_types#create', via: :put, as: :create

  match 'organisations/save_current_organisation', to: 'organisations#save_current_organisation', via: :post
  match "organisations/accept_organisation_invitation", to: 'organisations#accept_organisation_invitation', via: :post


  match 'organisations/invite', to: 'organisations#inviteSubmission', via: :post

  match "your_documents" => 'documents#your_documents', via: :post, as: 'your_documents'
  match "your_actions" => 'documents#your_actions', via: :post, as: 'your_actions'
  match "all_documents" => 'documents#all_documents', via: :post, as: 'all_documents'

  root to: "organisations#index"

  mount Rapidfire::Engine => "/rapidfire"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
