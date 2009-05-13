module Webbastic
  module WidgetModules
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
        backContent = ""
        # Widget has gallery_id header, just display this gallery
        if gallery_id = self.header_content(:gallery_id)
          log "generate widget_content for #{self.page.name} with gallery #{gallery_id}"
          gallery = MediaRocket::Gallery.first(:id => gallery_id)
          backContent += "<div class='gallery_title'>" + (gallery.ref_title[0..20] || gallery.name[0..20]) + "</div>"
          backContent += list_html gallery.original_medias
        end
        backContent
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
        "<ul class='gallery_detail'>#{list}</ul>"
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