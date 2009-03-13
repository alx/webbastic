module Webbastic
  module Router
    
    def self.setup(scope)
      scope.identify DataMapper::Resource => :id do |s|
        s.resources :widgets, ::Webbastic::Widgets
        s.resources :sites, ::Webbastic::Sites do |r|
          r.resources :layouts, ::Webbastic::Layouts
          r.resources :pages,   ::Webbastic::Pages do |p|
            p.resources :widgets, ::Webbastic::Widgets
            p.resources :layouts, ::Webbastic::Layouts
          end
        end
      end

      # Url to generate a site
      scope.match('/sites/:id/generate').to(:controller => 'sites', :action => 'generate').name(:site_generate)
      
      scope.match('/sites/:id/medias').to(:controller => 'sites', :action => 'medias').name(:library)
      
      scope.match('/sites/:site_id/static_pages/:id/edit').to(:controller => 'pages', :action => 'static').name(:static_page_edit)
    end
    
  end
end