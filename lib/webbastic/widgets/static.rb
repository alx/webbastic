module Webbastic
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
    
  end
end
