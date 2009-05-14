module Webbastic
  module WidgetModules
    module GalleryBuilderWidget
      #
      # Media Rocket Gallery Builder
      #
      # When this widget is included in a page
      # and the page is generated:
      #   - a list of galleries is displayed on the widget's page
      #   - each element of this gallery link to another page
      #
  
      def widget_headers
        [['gallery_columns', '4']]
      end
  
      def edit_partial
        columns_header = self.has_header?(:gallery_columns) || self.add_header(:gallery_columns, 4)
    
        linked_galleries = ""
        if header = self.has_header?(:linked_galleries)
          linked_galleries = tag(:input, {:id => 'linked-galleries', :value => header.content, :type => 'hidden'})
        end
    
        tag(:h2, "Options") <<
        tag(:p, "Number of columns: " << edit_header(columns_header)) <<
        tag(:h2, "Select Galleries to display") <<
        tag(:span, "<a href='#' class='select_all'>Select all</a> || <a href='#' class='deselect_all'>Deselect all</a>") <<
        list_html(MediaRocket::Gallery.all) <<
        linked_galleries <<
        tag(:input, {:id => 'current-widget',   :value => self.id, :type => :hidden})
      end
  
      def edit_header(header)
    
        editable_script = "
          $(document).ready(function() {
    				$('#edit_header_#{header.id}').editable('#{Merb::Router.url(:webbastic_header, :id => header.id)}', {
    					type     	: 'text',
    					method		: 'PUT',
    					name		: 'header[content]',
    					submitdata 	: {id: '#{header.id}'}
    				});
    			});
        "
    
        tag(:span, header.content, {:class => :editable,
                                    :id => "edit_header_#{header.id}",
                                    :style => "display: inline"}) <<
        tag(:script, editable_script, {:type => "text/javascript",
                                       :charset => "utf-8"})
      end
  
      def widget_content
    
        if checked_galleries = self.header_content("displayed_galleries")
          @galleries = MediaRocket::Gallery.all(:id => checked_galleries.split(',').collect{|x| x.to_i})
        else
          @galleries = MediaRocket::Gallery.all
        end
        
        linked_galleries = self.header_content("linked_galleries")
    
        columns = self.header_content("gallery_columns").to_i
        list = "<table>"
        while @galleries.size > 0 do
          list << "<tr>"
          columns.times do
            if gallery = @galleries.pop
              
              list << "<td class='gallery_line'><span class='gallery_title'>" << (gallery.ref_title || gallery.name) << "<br></span>"
              if linked_galleries && match = Regexp.new("," << gallery.id << "(.[^,]*)").match(linked_galleries)
                gallery_url = match[1]
              end
              
              if gallery_url
                list << "<a href='" << gallery_url << "'><img src='" << gallery.icon << "'></a><br>"
              else
                page = create_gallery_page(gallery)
                list << "<a href='" << page.link << "'><img src='" << gallery.icon << "'></a><br>"
              end
              
              list << "</td>"
            end
          end
          list << "</tr>"
        end
        list << "</table>"
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
      def list_html(galleries)
    
        if checked_galleries = self.header_content("displayed_galleries")
          checked_galleries = checked_galleries.split(',').collect{|x| x.to_i}
        else
          all_checked = true
        end
    
        linked_galleries = self.header_content("linked_galleries")
        
        list = "<table><tr>"
        column = 0
        galleries.each do |gallery|
          
          if linked_galleries && match = Regexp.new("," << gallery.id << "(.*)?,").match(linked_galleries)
            gallery_url = match[1]
          end
          
          Merb.logger.debug "list_html gallery.id: #{gallery.id}"
          Merb.logger.debug "list_html gallery_url: #{gallery_url}"
      
          select_gallery = "<input class='checkbox_gallery' type='checkbox' name='gallery_#{gallery.id}'"
          if all_checked || checked_galleries.include?(gallery.id)
            select_gallery << "CHECKED"
          end
          select_gallery << "/><br/><label for='checkbox_gallery'>Display</label><br/>"
          
          mode_gallery = "<form><input type='radio' class='mode-display gallery-#{gallery.id}'"
          mode_gallery << "CHECKED" unless gallery_url
          mode_gallery << ">Gallery</input><br/>"
          mode_gallery << "<input type='radio' class='mode-external gallery-#{gallery.id}' alt='#{gallery_url}'"
          mode_gallery << "CHECKED" if gallery_url
          mode_gallery << ">External Link</input></form>"
      
          img = "<td><img src='" << gallery.icon << "'><br>" << gallery.title << select_gallery << mode_gallery << "</td>"
          list << img
      
          column += 1
          if column % 4 == 0
            list << "<tr></tr>"
          end
        end
        list << "</tr></table>"
      end # def list_html
    end
  end
end