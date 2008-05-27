ActionController::Routing::Routes.draw do |map|

  map.resource :sessions
  map.resources :users do |user|
    # UserAssetsController knows how to deal with the 
    # polymorphic relationship between an Asset and its
    # 'attachable'.  
    # We use the resource_fu :opaque_name option so that the
    # url looks clean independent of url helper and route names.
    user.resources :user_assets, :opaque_name => :assets
  end
  
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect '', :controller => 'users'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
