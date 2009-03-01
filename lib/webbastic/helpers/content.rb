module Webbastic
  module Helpers
    module Content
      
      # Construct admin menu to be placed on top of edited site
      def admin_menu(site_id)
        if site = ::Webbastic::Site.first(:id => site_id)
          tag :div, :id => "admin_menu" do
            tag :div, :id => "admin_menu_buttons" do
              tag(:div, 
                  "Current site: <b>#{site.name}</b><br><span class='#{site.status}'>#{site.status}</span>", 
                  :id => "admin_menu_status") <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/world.png")) + "site", 
                  {:href => slice_url(:generated_site, site.id),:class => "button"}) <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/photos.png")) + "layouts",
                  {:href => slice_url(:site_layouts, site.id),:class => "button"}) <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/page.png")) + "pages",
                  {:href => slice_url(:site_pages, site.id),:class => "button"}) <<
              tag(:a, 
                  self_closing_tag(:img, :src => webbastic_image_path("/icons/package.png")) + "library",
                  {:href => slice_url(:library, site.id),:class => "button"}) <<
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