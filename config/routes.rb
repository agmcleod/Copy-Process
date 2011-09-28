CopyProcess::Application.routes.draw do
  resources :sites do
    resources :documents
    resources :element_types
    resources :elements, only: [:index]
    resource :search_and_replace, only: [:new, :create], controller: 'search_and_replace'
  end
  
  root to: 'sites#index'
  
  match '/compile_documents/:id' => 'sites#compile_documents', :as => :compile_documents, :via => :post
  match '/export_as_csv/:id' => 'sites#export_csv', :as => :export_csv, :via => :get
end
