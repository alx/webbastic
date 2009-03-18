Merb::Router.prepare do |scope|
    
  scope.identify DataMapper::Resource => :id do |s|
     s.resources :widgets, ::Webbastic::Widgets
    s.resources :sites,   "Webbastic::Sites" do |r|
      r.resources :layouts, "Webbastic::Layouts"
      r.resources :pages,   "Webbastic::Pages" do |p|
        p.resources :widgets, "Webbastic::Widgets"
        p.resources :layouts, "Webbastic::Layouts"
      end
    end
  end

  # Url to generate a site
  scope.match('/sites/:id/generate').to(:controller => 'sites', :action => 'generate').name(:webbastic_generate_site)
  scope.match('/sites/:id/content').to(:controller => 'sites', :action => 'content').name(:webbastic_site_content)

  scope.match('/sites/:id/medias').to(:controller => 'sites', :action => 'medias').name(:library)

end