module Webbastic
  module Helpers
    module Content
      
      #
      # Construct admin menu to be placed on top of edited site
      #
      def admin_menu(site_id)
        
        # Create new site with Merb.root name if current site_id not found
        unless site = ::Webbastic::Site.first(:id => site_id)
          # TODO: replace Merb.root[/\/(.[^\/]*)$/,1] by something more elegant
          site = ::Webbastic::Site.create(:id => site_id, :name => Merb.root[/\/(.[^\/]*)$/,1])
        end
        
        admin_layout(site)
      end
      
      #
      # Build admin menu
      #
      def admin_layout(site)
        tag :div, :id => "admin_menu" do
          tag :div, :id => "admin_menu_buttons" do
            admin_status(site) <<
            tag(:a, 
                self_closing_tag(:img, :src => webbastic_image_path("/icons/world.png")) + "site", 
                {:href => "/",:class => "button"}) <<
            tag(:a, 
                self_closing_tag(:img, :src => webbastic_image_path("/icons/photos.png")) + "layouts",
                {:href => url(:webbastic_site_layouts, site.id),:class => "button"}) <<
            tag(:a, 
                self_closing_tag(:img, :src => webbastic_image_path("/icons/page.png")) + "pages",
                {:href => url(:webbastic_site_pages, site.id),:class => "button"}) <<
            media_rocket_button <<
            tag(:a, 
                self_closing_tag(:img, :src => webbastic_image_path("/icons/wrench_orange.png")) + "configuration",
                {:href => url(:edit_webbastic_site, site.id),:class => "button"})
          end
        end
      end
      
      #
      # Display site status in a div
      # with a link to generate the website
      #
      def admin_status(site)
        tag(:div, 
            "Current site: <b>#{site.name}</b><br>
            <span class='#{site.status}'><a href='#{url(:webbastic_site_generate, site.id)}'>generate</a></span>", 
            :id => "admin_menu_status")
      end
      
      #
      # Verify that media_rocket is defined in current Merb App
      # and create a button for it
      #
      def media_rocket_button
        if Merb.const_defined? :MediaRocket
          tag(:a, 
              self_closing_tag(:img, :src => webbastic_image_path("/icons/package.png")) + "library",
              {:href => "/admin/medias",:class => "button"})
        else
          "" # Not defined, return string
        end
      end
      
    end
  end
end