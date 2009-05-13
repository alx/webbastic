module Webbastic
  module Widgets
    module MediaListWidget
  
      #
      # Media Rocket Media List
      #
      # This widget generate a list of the original media 
      # from the gallery specified in gallery_id header
      #
  
      def edit_partial
        list_html(MediaRocket::Gallery.all)
      end

      def widget_content
        # Widget has gallery_id header, just display this gallery
        if gallery_id = self.header_content(:gallery_id)
          log "generate widget_content for #{self.page.name} with gallery #{gallery_id}"
          list_html MediaRocket::Gallery.first(:id => gallery_id).original_medias
        end
      end # def widget_content
  
      # Build hmtl content for a list of media or gallery
      # as long as the object accepts .thumbnail method
      def list_html(medias)
        list = ""
        log "list_html: #{medias.size}"
        medias.each do |media|
          log "media: #{media.title}"
          list << "<li><img src='" << media.url << "'><br>" << media.title << "</li>"
        end
        "<ul>#{list}</ul>"
      end # def list_html
  
      def log(message)
        Merb.logger.debug " ===== "
        Merb.logger.debug " [Webbastic::Helpers::Widgets::MediaListWidget]"
        Merb.logger.debug message
        Merb.logger.debug " ===== "
      end
    end # class MediaListWidget
  end
end