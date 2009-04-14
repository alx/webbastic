module Webbastic
  module Widgets

    module GalleryBuilderWidget
      #
      # Media Rocket Gallery Builder
      #
      # When this widget is included in a page
      # and the page is generated:
      #   - a list of galleries is displayed on the widget's page
      #   - each element of this gallery link to another page
      #
  
      def edit_partial
        list_html(MediaRocket::Gallery.all)
      end
  
      def widget_content
        list = ""
        MediaRocket::Gallery.all.each do |gallery| 
          page = create_gallery_page(gallery)
          list << "<li><a href='" << page.link << "'><img src='" << gallery.icon << "'></a><br>"
          list << page.name << "</li>"
        end
        list
      end # def widget_content
  
      def create_gallery_page(gallery)
        # Create a new associated page that'll store the specific gallery
        log "create new page for gallery: #{gallery.name} - #{gallery.id}"
        current_site = self.page.site
        unless gallery_page = current_site.pages.first(:name => gallery.name)
          gallery_page = current_site.pages.create :name => gallery.name
          gallery_page.associated_pages.create(:parent_page => self.page)
          # Create a widget with the necessary gallery_id
          widget = gallery_page.widgets.create :module => "MediaListWidget"
          widget.add_header "gallery_id", gallery.id
          # Write file that would be display on site
          log "generate page #{gallery_page.name}"
          gallery_page.write_file
        end
        gallery_page
      end
  
      def log(message)
        Merb.logger.info " ===== "
        Merb.logger.info " [Webbastic::Helpers::Widgets::GalleryBuilderWidget]"
        Merb.logger.info message
        Merb.logger.info " ===== "
      end
  
      # Build hmtl content for a list of media or gallery
      # as long as the object accepts .thumbnail method
      def list_html(medias)
        list = ""
        log "list_html: #{medias.size}"
        medias.each do |media|
          log "media: #{media.title}"
          list << "<li><img src='" << media.icon << "'><br>" << media.title << "</li>"
        end
        "<ul>#{list}</ul>"
      end # def list_html
    end

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
        if gallery_id = self.header_content('gallery_id')
          log "generate widget_content for #{self.page.name} with gallery #{gallery_id}"
          list_html MediaRocket::Gallery.get(gallery_id).original_medias
        end
      end # def widget_content
  
      # Build hmtl content for a list of media or gallery
      # as long as the object accepts .thumbnail method
      def list_html(medias)
        list = ""
        log "list_html: #{medias.size}"
        medias.each do |media|
          log "media: #{media.title}"
          list << "<li><img src='" << media.icon << "'><br>" << media.title << "</li>"
        end
        "<ul>#{list}</ul>"
      end # def list_html
  
      def log(message)
        Merb.logger.info " ===== "
        Merb.logger.info " [Webbastic::Helpers::Widgets::MediaListWidget]"
        Merb.logger.info message
        Merb.logger.info " ===== "
      end
    end # module MediaListWidget
    
  end
end