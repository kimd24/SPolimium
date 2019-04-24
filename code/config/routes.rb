Rails.application.routes.draw do
  get 'legislators/index'
  get 'cocktails/index'
  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
 # root 'static_pages#home'
  #root 'cocktails#index'
  resources 'legislators'
  root 'legislators#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
