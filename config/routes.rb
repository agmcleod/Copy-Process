CopyProcess::Application.routes.draw do

  devise_for :users, :skip => [:registrations] do
    get "/login" => "devise/sessions#new", :as => :login
    post '/login' => "devise/sessions#create"
    get "/logout" => "devise/sessions#destroy", :as => :logout
  end

  resources :sites do
    resources :documents, except: :index
    resources :element_types, :only => [:index, :show, :destroy, :edit, :update]
    resources :elements, :only => [:index]
    resource :search_and_replace, :only => [:new, :create], :controller => 'search_and_replace'
  end
  
  resources :versions, only: :show do
    resources :notes, :except => [:show, :new, :edit]
  end
  
  
  resources :documents do
    resources :versions, only: :create
  end
  
  root :to => 'sites#index'
  
  match '/compile_documents/:id' => 'sites#compile_documents', :as => :compile_documents, :via => :post
end
