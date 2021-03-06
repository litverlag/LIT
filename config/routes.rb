Rails.application.routes.draw do

  devise_for :users

  get '/chef/produktion', to: 'chef#produktion'
  get '/chef/terminplanung', to: 'chef#index'

  get '/preps', to: 'preps#index'
  get '/preps/stati', to: 'preps#stati'
  post '/preps/editStatus', to: 'preps#editStatus'

  get '/satz', to: 'satz#index'
  get '/satz/stati', to: 'satz#stati'
  post '/satz/editStatus', to: 'satz#editStatus'

  get '/binderei', to: 'bindung#index'
  get '/binderei/stati', to: 'bindung#stati'
  post '/binderei/editStatus', to: 'bindung#editStatus'

  get '/druck/produktion', to: 'druck#produktion'
  get '/druck/produktion/edit/:id', to: 'druck#editProduktion'
  post '/druck/produktion/update', to: 'druck#updateProduktion'
  get '/druck/terminplanung', to: 'druck#index'
  get '/druck/stati', to: 'druck#stati'
  post '/druck/editStatus', to: 'druck#editStatus'

  get '/umschlag/produktion', to: 'umschlag#produktion'
  get '/umschlag/terminplanung', to: 'umschlag#index'
  get '/umschlag/stati', to: 'umschlag#stati'
  post '/umschlag/editStatus', to: 'umschlag#editStatus'

  get '/titelei/produktion', to: 'titelei#produktion'
  get '/titelei/produktion/edit/:id', to: 'titelei#editProduktion'
  post '/titelei/produktion/update', to: 'titelei#updateProduktion'
  get '/titelei/terminplanung', to: 'titelei#index'
  get '/titelei/stati', to: 'titelei#stati'
  post '/titelei/editStatus', to: 'titelei#editStatus'

  get '/lektor/produktion', to: 'lektor#produktion'
  get '/lektor/produktion/new', to: 'lektor#newProduktion'
  post '/lektor/produktion/create', to: 'lektor#createProduktion'
  get '/lektor/produktion/edit/:id', to: 'lektor#editProduktion'
  post '/lektor/produktion/update', to: 'lektor#updateProduktion'
  get '/lektor/terminplanung', to: 'lektor#index'

  root "application#index"
  match '*', to: "application#index", via: :all
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
