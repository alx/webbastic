module Webbastic
  module Helpers
    module Assets
      def webbastic_image_path(*segments)
        webbastic_public_path_for(:image, *segments)
      end

      def webbastic_javascript_path(*segments)
        webbastic_public_path_for(:javascript, *segments)
      end

      def webbastic_stylesheet_path(*segments)
        webbastic_public_path_for(:stylesheet, *segments)
      end
      
      def webbastic_upload_path(*segments)
        webbastic_public_path_for(:upload, *segments)
      end

      def webbastic_public_path_for(type, *segments)
        ::Webbastic.public_path_for(type, *segments)
      end
      
      def webbastic_js
        script = ""
        ['jquery/jquery.js',
         'jquery/jquery.ui.js',
         'jquery/jquery.livequery.js',
         'jquery/jquery.wymeditor.js',
         'jquery/jquery.jeditable.js',
         'jquery/jquery.filetree.js',
         'jquery/jquery.alerts.js'].each do |file|
          script << webbastic_js_line(file)
        end
        
        if Merb.const_defined? :MediaRocket
          script << webbastic_js_line('media_rocket.js')
        end
        
        script << webbastic_js_line('master.js')
      end
      
      def webbastic_js_line(file)
        "<script src='#{webbastic_javascript_path file}' type='text/javascript' charset='utf-8'></script>"
      end
      
      def webbastic_css
        ['master.css',
         'jquery.filetree.css',
         'jquery.alerts.css'].each do |file|
          css << media_rocket_css_line(file)
        end
        css
      end
      
      def webbastic_css_line(file)
        "<link rel='stylesheet' href='#{webbastic_stylesheet_path file}' type='text/css' media='screen, projection'>"
      end
    end
  end
end