module Webbastic
  module Widgets
   
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
   
  end
end
