module Webbastic
  module Helpers
    module Widgets
      
      class HeaderWidget < Webbastic::Widget
        
        def initialize(options)
          super
          self.name = "Header Widget"
          self.page_id = options[:page_id]
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
      
    end
  end
end