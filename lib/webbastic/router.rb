module Webbastic
  module Router
    
    def self.setup(scope)
      scope.identify DataMapper::Resource => :id do |s|
        s.resources :sites,   "Webbastic::Sites" do |r|
          r.resources :layouts, "Webbastic::Layouts"
          r.resources :pages,   "Webbastic::Pages" do |p|
            p.resources :widgets, "Webbastic::Widgets"
            p.resources :layouts, "Webbastic::Layouts"
          end
        end
      end

      # Url to generate a site and view content of generated site
      scope.match('/sites/:id/generate').to(:controller => 'sites', :action => 'generate').name(:site_generate)
      scope.match('/sites/:id/generated').to(:controller => 'sites', :action => 'generated').name(:site_generated)
      
      scope.match('/sites/:id/medias').to(:controller => 'sites', :action => 'medias').name(:library)
      
      scope.match('/').to(:controller => 'sites', :action => 'index').name(:home)
    end
    
  end
end