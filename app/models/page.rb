class Webbastic::Page
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :created_at, DateTime
  
  # Generated values are a stored text generated from 
  # the relationship with children objects
  property :generated_header, Text, :default => ""
  property :generated_content, Text, :default => ""
  
  belongs_to :site,   :class_name => Webbastic::Site
  belongs_to :layout, :class_name => Webbastic::Layout
  
  has n, :headers,  :class_name => Webbastic::Header
  has n, :widgets,  :class_name => Webbastic::Widget
  
  # =====
  #
  # Page generation
  #
  # =====
  
  def write_page_file
    self.generate
    # Write generated page to static file
    File.unlink self.path
    File.open self.path, "r+" do |f|
      f.write(self.generated_header)
      f.write(self.generated_content)
    end # File.open
  end
  
  def generate
    generate_header
    generate_content
  end
  
  # Generate YAML header from current page eader and its children
  def generate_header
    
    
    self.reload
    self.headers.reload
    
    # Default header values
    yaml_headers = {'title' => self.name, 
                    'created_at' => Time.now,
                    'extension' => 'html',
                    'filter' => 'erb',
                    'layout' => self.layout_path}
                        
    self.headers.each do |header|
      yaml_headers[header.name] = header.content
    end
    
    update_attributes(:generated_header => YAML::dump(yaml_headers) + "---\n")
    Merb.logger.info "generated_header: #{self.generated_header}"
  end
  
  def generate_content
    
    self.reload
    self.widgets.reload
    
    content = ""
    
    Merb.logger.info "widgets: #{self.widgets.size} - #{self.widgets.class}"
    self.widgets.each do |widget|
      Merb.logger.info "generate_content with widget: #{widget.name} - #{widget.class} - #{widget.created_at}"
      content += (widget.content || "")
    end
    
    update_attributes(:generated_content => content)
    Merb.logger.info "generate_content: #{self.generated_content}"
  end
  
  # =====
  #
  # Headers
  #
  # =====
  
  def add_header(name, content)
    if header = self.headers.first(:name => name)
      header.update_attributes(:content => content)
    else
      Webbastic::Header.create :name => name,
                               :content => content,
                               :page_id => self.id
    end
  end
  
  def header_content(header_name)
    if header = self.headers.first(:name => header_name)
      return header.content
    end
  end
  
  # =====
  #
  # Widgets
  #
  # =====
  
  def add_static_content(content)
    self.static_widget.update_attributes :content => content
  end
  
  # return a static widget linked to this page
  def static_widget
    
    # look for existing static widget
    self.widgets.each do |widget| 
      return widget if widget.name == "Static Widget"
    end
    
    # create widget if non-existent
    self.add_widget Webbastic::Helpers::Widgets::StaticWidget.new(:page_id => self.id)
  end
  
  def add_widget(widget)
    widget.save
    self.widgets << widget
    widget
  end
  
  # =====
  #
  # Misc
  #
  # =====
  
  def path
    File.join(self.site.content_dir, self.name + ".txt")
  end
  
  def layout_path
    Merb.logger.info "self.layout: #{self.layout}"
      Merb.logger.info "site.layout: #{self.site.default_layout.name}"
    layout = self.layout || self.site.default_layout
    layout.path
  end
end
