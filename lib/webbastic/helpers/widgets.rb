module Webbastic
  module Helpers
    module Widgets
      
      # Store static content in this widget
      class StaticWidget < Webbastic::Widget
        
        def initialize(options)
          self.name = "Static Widget"
          self.page_id = options[:page_id]
          super
        end
        
      end
      
      class HeaderWidget < Webbastic::Widget
        
        def initialize(options)
          self.name = "Header Widget"
          self.page_id = options[:page_id]
          super
        end
        
        def widget_headers
          [['width', '100%'], ['border', '1px solid #333']]
        end
        
        def widget_content
          "<div class='column span-20 prepend-2 append-2 first last' id='header'>
             <p class='title'>A New Website</p>
             <hr>
           </div>"
        end
        
      end
     
     if Merb.const_defined? :MediaRocket
      class MediaListWidget < Webbastic::Widget
        def initialize(options)
          super
          self.name = "Media List"
          self.page_id = options[:page_id]
          super
        end

        def widget_headers
          [['gallery_id', 1]]
        end
        
        def gallery_id
          self.headers.first(:name => 'gallery_id').content
        end

        def widget_content
          if Merb.const_defined? :MediaRocket
            # Find gallery header, and be sure some galleries are inside the system
            # if not present, display all galleries thumbnail
            if MediaRocket::Gallery.all.size > 0
              gallery = MediaRocket::Gallery.first(:id => self.gallery_id)
              content = list_html(gallery.medias.select{|media| media.original?})
            else
              content = list_html(MediaRocket::Gallery.all)
            end
          end
        end # def widget_content
        
        # Build hmtl content for a list of media or gallery
        # as long as the object accepts .thumbnail method
        def list_html(medias)
          list = ""
          medias.each do |media|
            list << "<li><img src='" << media.thumbnail << "'></li>"
          end
          "<ul>#{list}</ul>"
        end # def list_html
      end # class MediaListWidget
    end # if Merb.const_defined? :MediaRocket
      
    end
  end
end