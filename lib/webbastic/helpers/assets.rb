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
    end
  end
end