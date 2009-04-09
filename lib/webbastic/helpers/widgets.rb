module Webbastic
  module Helpers
    module Widgets
      
      # Store static content in this widget
      module StaticWidget
        
        def edit_partial
          
          input_method = self_closing_tag :input, {:type => :hidden, 
                                                   :name => :_method, 
                                                   :value => :put}
                                                   
          input_area = tag :textarea, "", {:name => "widget[content]", 
                                           :rows => 20, 
                                           :cols => 100,
                                           :class => :wymeditor}
                                          
          submit = self_closing_tag :input, {:type => :submit, 
                                             :value => "Update Content", 
                                             :class => "wymupdate"}
          
          
          form = tag :form, input_method + input_area + submit, {:action => Merb::Router.url(:webbastic_widget, :id => self.id), 
                                                                 :method => :post}
          
          script = tag :script, "$('.wymeditor').wymeditor({html:'#{self.content}'});",
                      {:type => "text/javascript"}
                      
          form + script
        end
        
      end
      
      module RssWidget
        
        def edit_partial
          input_method = self_closing_tag :input, {:type => :hidden, 
                                                   :name => :_method, 
                                                   :value => :put}
          
          input_area = header_input("rss_link") << "<br/>" << header_input("rss_item_lenght")
                                                   
          form = tag :form, input_method + text_area + submit, {:action => Merb::Router.url(:webbastic_widget, :id => self.id), 
                                                                :method => :post}
        end
        
        def header_input(header_name)
          header = self.headers.first(:name => header_name).content
          dom_id = "header-#{header_name}-#{header.id}"
          tag :label, header_name, {:for => dom_id} do
            tag :input, header, {:name  => "widget[header][#{header_name}]", 
                                 :type  => :text, 
                                 :id    => dom_id,
                                 :class => "input-header"}
          end
        end
        
        def widget_headers
          [['rss_link', 'http://alexgirard.com/rss.xml'], 
          ['rss_items', '5'],
          ['rss_item_length', '0']]
        end
        
        def widget_content
          rss_link        = self.headers.first(:name => 'rss_link').content
          rss_item_length = self.headers.first(:name => 'rss_item_length').content
          rss             = Hpricot(open(rss_link))

          out = "<ul>\n"
          rss.search("source").each do |source|
            break if source.nil?
            out << "<li><a href='#{source[:url]}'>#{truncate_words(source.inner_html, rss_item_length)}</a></li>"
          end
          out << "\n</ul>\n"
        end
        
        def truncate_words(text, length = 30, end_string = ' …')
          return if text == nil
          return text if length == 0
          
          words = text.split()
          words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
        end
      end
     
     if Merb.const_defined? :MediaRocket
      module MediaListWidget
        
        def edit_partial
          list_html(MediaRocket::Gallery.all)
        end
        
        def gallery_id
          self.headers.first(:name => 'gallery_id').content
        end

        def widget_content
          # Widget has gallery_id header, just display this gallery
          if gallery_id
            list_html MediaRocket::Gallery.first(:id => gallery_id).original_medias
          else
            MediaRocket::Gallery.all.each do |gallery|
              # Create new widget with specific gallery to display
              @widget = MediaListWidget.create
              @widget.headers.create :name => :gallery_id, :content => gallery.id
              # Create an associated page to display this widget
              @page = self.page.associated_pages.create :name => gallery.name
              @page.add_widget @widget
            end
          end
        end # def widget_content
        
        # Build hmtl content for a list of media or gallery
        # as long as the object accepts .thumbnail method
        def list_html(medias)
          list = ""
          medias.each do |media|
            list << "<li><img src='" << media.icon << "'><br>" << media.title << "</li>"
          end
          "<ul>#{list}</ul>"
        end # def list_html
      end # class MediaListWidget
    end # if Merb.const_defined? :MediaRocket
      
    end
  end
end