module Merb
  module Webbastic
    module ApplicationHelper
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def image_path(*segments)
        public_path_for(:image, *segments)
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def javascript_path(*segments)
        public_path_for(:javascript, *segments)
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def stylesheet_path(*segments)
        public_path_for(:stylesheet, *segments)
      end
      
      # Construct a path relative to the public directory
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def public_path_for(type, *segments)
        ::Webbastic.public_path_for(type, *segments)
      end
      
      # Construct an app-level path.
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path within the host application, with added segments.
      def app_path_for(type, *segments)
        ::Webbastic.app_path_for(type, *segments)
      end
      
      # Construct a slice-level path.
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path within the slice source (Gem), with added segments.
      def slice_path_for(type, *segments)
        ::Webbastic.slice_path_for(type, *segments)
      end
      
      # Construct admin menu to be placed on top of edited site
      def admin_menu
        tag :div, :id => "admin_menu" do
          tag :div, :id => "admin_menu_buttons" do
            tag(:a, self_closing_tag(:img, :src => webbastic_image_path("/icons/world.png")) + "site", :class => "button") <<
            tag(:a, self_closing_tag(:img, :src => webbastic_image_path("/icons/photos.png")) + "layouts", :class => "button") <<
            tag(:a, self_closing_tag(:img, :src => webbastic_image_path("/icons/page.png")) + "pages", :class => "button") <<
            tag(:a, self_closing_tag(:img, :src => webbastic_image_path("/icons/package.png")) + "library", :class => "button") <<
            tag(:a, self_closing_tag(:img, :src => webbastic_image_path("/icons/wrench_orange.png")) + "configuration", :class => "button")
          end
        end
      end
      
    end
  end
end