module Webbastic
  module Helpers
    module Content
      
      # Construct admin menu to be placed on top of edited site
      def admin_menu(site_id)
        if site = ::Webbastic::Site.first(:id => site_id)
          
          # add media_rocket tab if possible
          media_rocket = ""
          if Merb.const_defined? :MediaRocket
            media_rocket = tag(:a, 
                               self_closing_tag(:img, :src => webbastic_image_path("/icons/package.png")) + "library",
                               {:href => url(:media_rocket_index),:class => "button"})
          end
          
          tag :div, :id => "admin_menu" do
            tag :div, :id => "admin_menu_buttons" do
              tag(:div, 
                  "Current site: <b>#{site.name}</b><br>
                  <span class='#{site.status}'><a href='#{url(:webbastic_site_generate, site.id)}'>generate</a></span>", 
                  :id => "admin_menu_status") <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/world.png")) + "site", 
                  {:href => "/",:class => "button"}) <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/photos.png")) + "layouts",
                  {:href => url(:webbastic_site_layouts, site.id),:class => "button"}) <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/page.png")) + "pages",
                  {:href => url(:webbastic_site_pages, site.id),:class => "button"}) <<
              media_rocket <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/wrench_orange.png")) + "configuration",
                  {:href => url(:edit_webbastic_site, site.id),:class => "button"})
            end
          end
        end
      end
      
    end
  end
end