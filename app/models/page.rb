class Webbastic::Page
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :created_at, DateTime
  
  # Generated values are a stored text generated from 
  # the relationship with children objects
  property :generated_header, Text, :default => ""
  property :generated_content, Text, :default => ""
  
  belongs_to :site,         :class_name => Webbastic::Site
  belongs_to :layout,       :class_name => Webbastic::Layout
  belongs_to :content_dir,  :class_name => Webbastic::ContentDir
  
  has n, :headers,  :class_name => Webbastic::Header
  has n, :widgets,  :class_name => Webbastic::Widget
  
  before :destroy, :delete_page
  
  # =====
  #
  # File Path
  #
  # =====
  
  def relative_path(options = {})
    File.join(self.site.content_dir(options), self.name)
  end
  
  def absolute_path
    relative_path(:absolute => true)
  end
  
  # Write generated page to static file
  def write_file
    self.generate
    
    filename = self.absolute_path.gsub(".txt", "")
    
    # Write generated page to static file
    delete_file
    File.open(filename, 'w+') do |f| 
      f.write(self.generated_header)
      f.write(self.generated_content)
    end
  end
  
  def delete_file
    filename = self.absolute_path.gsub(".txt", "")
    File.delete filename if File.exists? filename
  end
  
  # =====
  #
  # Page generation
  #
  # =====
  
  def generate
    generate_header
    generate_content
  end
  
  # Generate YAML header from current page eader and its children
  def generate_header
    
    self.reload
    self.headers.reload
    
    layout = self.current_layout.relative_path unless self.current_layout.nil?
    
    # Default header values
    yaml_headers = {'title' => self.name, 
                    'created_at' => Time.now,
                    'extension' => 'html',
                    'filter' => 'erb',
                    'layout' => layout}
                        
    self.headers.each do |header|
      yaml_headers[header.name] = header.content
    end
    
    update_attributes(:generated_header => YAML::dump(yaml_headers) + "---\n")
  end
  
  def generate_content
    
    self.reload
    self.widgets.reload
    
    content = ""
    
    self.widgets.each do |widget|
      content += (widget.content || "")
    end
    
    update_attributes(:generated_content => content)
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
  # Layout
  #
  # =====
  
  def current_layout
    self.layout || (self.site.default_layout unless self.site.nil?)
  end
  
  # =====
  #
  # Misc
  #
  # =====
end