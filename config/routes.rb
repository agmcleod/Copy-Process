CopyProcess::Application.routes.draw do

  resources :sites do
    resources :documents
  end
  
  root to: 'sites#index'
  
  match '/compile_documents/:id' => 'sites#compile_documents', :as => :compile_documents, :via => :post
end
