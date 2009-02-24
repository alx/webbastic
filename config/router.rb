Merb::Router.prepare do |scope|
  scope.identify DataMapper::Resource => :id do |s|
    scope.resources :sites,   "Webbastic::Sites"
    scope.resources :pages,   "Webbastic::Pages"
    scope.resources :widgets, "Webbastic::Widgets"
    scope.resources :layouts, "Webbastic::Layouts"
  end

  # Url to generate a site and view content of generated site
  scope.match('/sites/:id/generate').to(:controller => 'sites', :action => 'generate').name(:generate_site)
  scope.match('/sites/:id/generated').to(:controller => 'sites', :action => 'generated').name(:generated_site)
  
  scope.match('/').to(:controller => 'sites', :action => 'index').name(:home)
end