module Webbastic
  module Helpers
    module Widgets
      
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

        def widget_content
          gallery_id = self.headers.first(:name => 'gallery_id').content
          gallery = ::MediaRocket::Gallery.first(:id => gallery_id)
          medias = gallery.medias.select{|media| media.original?}

          content = "<ul>"
          medias.each do |media|
            content << "<li><a href='#{media.url}'>#{media.url}</a></li>"
          end
          content << "</ul>"
        end
      end
      
    end
  end
end