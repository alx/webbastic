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
      
      # Store static content in this widget without the need for editor
      module CodeWidget
        
        def edit_partial
          
          input_method = self_closing_tag :input, {:type => :hidden, 
                                                   :name => :_method, 
                                                   :value => :put}
                                                   
          input_area = tag :textarea, "#{self.content}", {:name => "widget[content]", 
                                                          :rows => 20, 
                                                          :cols => 100,
                                                          :class => "contentarea"}
                                          
          submit = self_closing_tag :input, {:type => :submit, 
                                             :value => "Update Content", 
                                             :class => "wymupdate"}
          
          
          form = tag :form, input_method + input_area + submit, {:action => Merb::Router.url(:webbastic_widget, :id => self.id), 
                                                                 :method => :post}
                      
          form
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
          header = self.header_content(header_name)
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
          rss_link        = self.header_content 'rss_link'
          rss_item_length = self.header_content 'rss_item_length'
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
          tag(:h2, "Select Galleries to display") <<
          tag(:span, "Select all || Deselect all") <<
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
            gallery_page.widgets.reload
            
            # Add header to not display this page in the admin
            gallery_page.headers.create :name => "admin_page_show", :content => "false"
            gallery_page.headers.reload
            
            # Write file that would be display on site
            log "generate page #{gallery_page.name}"
            gallery_page.write_file
          end
          gallery_page
        end
        
        def log(message)
          Merb.logger.debug " ===== "
          Merb.logger.debug " [Webbastic::Helpers::Widgets::GalleryBuilderWidget]"
          Merb.logger.debug message
          Merb.logger.debug " ===== "
        end
        
        # Build hmtl content for a list of media or gallery
        # as long as the object accepts .thumbnail method
        def list_html(medias)
          list = ""
          medias.each do |media|
            select_gallery = "<input class='checkbox_gallery' type='checkbox' value='something' name='gallery_#{media.id}'/>"
            select_gallery << "<label for='checkbox_gallery'>Display</label>"
            img = "<li><img src='" << media.icon << "'><br>" << media.title << select_gallery << "</li>"
            list << img
          end
          "<ul>#{list}</ul>"
        end # def list_html
      
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
          Merb.logger.debug " ===== "
          Merb.logger.debug " [Webbastic::Helpers::Widgets::MediaListWidget]"
          Merb.logger.debug message
          Merb.logger.debug " ===== "
        end
      end # class MediaListWidget
    end # if Merb.const_defined? :MediaRocket
      
    end
  end
end