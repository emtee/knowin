Govindata::Application.routes.draw do


  namespace :api do
    namespace :v1 do
      namespace :services do
        namespace :iphone do
          resources :basic do
            collection do
              post "signup"
              post "authenticate"
              post "get_datasets"
              post "update_settings"
            end
          end
          resources :sync do
            collection do
              get "/:action"
            end
          end
        end
      end
    end
  end

  # match "/create_default_admin" => "welcome#create_default_admin"
  authenticated :user do
    # root :to => "home#index"
    root :to => 'welcome#index'
  end
  
  devise_for :users do
    root to: "devise/sessions#new"
  end

    root :to => 'welcome#index'
  resources :datasets


  post "/welcome/upload" => "welcome#upload"

  # root :to => 'datasets#index'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
