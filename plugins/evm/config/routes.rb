# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# get 'evm', :to => 'evm#index'

resources :projects do
    resources :evm
    resources :evm_histories
end
