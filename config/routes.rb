CopyProcess::Application.routes.draw do

  get "element_types/index"

  resources :sites do
    resources :documents
    resources :element_types do
      resources :elements
    end
  end
  
  root to: 'sites#index'
  
  match '/compile_documents/:id' => 'sites#compile_documents', :as => :compile_documents, :via => :post
  match '/export_as_csv/:id' => 'sites#export_csv', :as => :export_csv, :via => :get
end
