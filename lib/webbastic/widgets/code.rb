module Webbastic
  module Widgets
    module CodeWidget
  
      # Store static content in this widget without the need for editor
  
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
  end
end