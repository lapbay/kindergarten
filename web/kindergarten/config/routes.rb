Howjoy::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_scope :user do
    post "/users", :as => "user_registration", :action => "create", :to => "api/registrations"
  end
  devise_for :users
  resources :users, :only => [:show, :index]

  namespace :api do
    devise_for :users, :controllers => {:sessions => "api/api_sessions"}

    resources :profiles, :only=>[:show, :index] do
      resources :friendships, :controller => "friendships", :except=>[:edit, :new]
      resources :tasks, :controller => "user_tasks"
      resources :feeds, :only=>[:index], :controller => "user_feeds"
    end

    resources :feeds
    resources :books
    resources :notifications, :only=>[:create, :index]
    resources :messages, :only=>[:create, :index]

    resources :records, :only=>[:show, :create, :index]

    resources :tasks
    resources :searches, :only=>[:create, :index]

  end

  namespace :admin do
    #devise_for :users, :controllers => {:sessions => "api/api_sessions"}

    resources :feeds, :only=>[:show, :index]

    resources :records, :only=>[:show, :create, :index]

    resources :tasks
  end

  #get "users/index"
  #get "users/edit"
  #resource :users
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end


