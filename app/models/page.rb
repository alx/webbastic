class Webbastic::Page
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :created_at, DateTime
  
  # Generated values are a stored text generated from 
  # the relationship with children objects
  property :generated_header, Text, :default => ""
  property :generated_content, Text, :default => ""
  
  belongs_to :site,         :class_name => Webbastic::Site,       :child_key => [:site_id]
  belongs_to :layout,       :class_name => Webbastic::Layout,     :child_key => [:layout_id]
  belongs_to :content_dir,  :class_name => Webbastic::ContentDir, :child_key => [:content_dir_id]
  
  has n, :headers,  :class_name => Webbastic::Header
  has n, :widgets,  :class_name => Webbastic::Widget
  
  # Force page generation on first time
  after :create, :create_defaults
  # after :update, :is_dirty
  
  # Delete page from filesystem
  before :destroy, :delete_page
  
  # =====
  #
  # Defaults
  #
  # =====
  
  def create_defaults
    self.headers.create :name => "extension", :content => "html"
    self.headers.create :name => "filter", :content => "erb"
    self.headers.create :name => "dirty", :content => true
  end
  
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
    
    # if dirty?
      generate
    
      filename = absolute_path.gsub(".txt", "")
      delete_file filename
      
      File.open(filename, 'w+') do |f| 
        f.write(generated_header)
        f.write(generated_content)
      end
    #   not_dirty
    # end
  end
  
  def delete_file(filename)
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
    not_dirty
  end
  
  # Generate YAML header from current page eader and its children
  def generate_header
    
    self.reload
    self.headers.reload
    
    layout_path = self.current_layout.relative_path unless self.current_layout.nil?
    
    # Default header values
    yaml_headers = {'title' => self.name, 
                    'created_at' => Time.now,
                    'layout' => layout_path}
                        
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
      widget.extend(widget.module) unless widget.module.empty?
      content += (widget.content || "")
    end
    
    update_attributes(:generated_content => content)
  end
  
  # =====
  #
  # Dirty
  #
  # =====
  
  # Make this page dirty, it'll force Webby to re-generate page
  def is_dirty
    self.headers.first_or_create(:name => :dirty)
  end
  
  # Remove dirty header for this page
  def not_dirty
    self.headers.first(:name => :dirty).destroy
  end
  
  # Verify if page is dirty
  def dirty?
    return !self.headers.first(:name => :dirty).nil?
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
      self.headers.create :name => name,
                          :content => content
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
    self.add_widget Webbastic::Widget.create :name => "Static Widget"
  end
  
  def add_widget(widget)
    widget.update_attributes :page_id => self.id
    self.widgets << widget
    self.reload
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