class Webbastic::Layout
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :created_at, DateTime
  
  # Generated values are a stored text generated from 
  # the relationship with children objects
  property :generated_header, Text, :default => ""
  property :generated_content, Text, :default => ""
  
  belongs_to :site, :class_name => Webbastic::Site, :child_key => [:site_id]
  
  has n, :pages, :class_name => Webbastic::Page
  has n, :headers, :class_name => Webbastic::Header
  
  # Force layout generation on first time
  after :create, :create_defaults
  
  # Add :dirty header to rewrite file during next generation
  # after :update, :is_dirty
  
  # =====
  #
  # Defaults
  #
  # =====
  
  def create_defaults
    self.headers.create :name => "extension", :content => "html"
    self.headers.create :name => "filter", :content => "erb"
    # self.headers.create :name => "dirty", :content => true
  end
  
  # =====
  #
  # File Path
  #
  # =====
  
  def relative_path(options = {})
    File.join(self.site.layout_dir(options), sanitize_filename(self.name))
  end
  
  def absolute_path
    relative_path(:absolute => true)
  end
  
  # Write generated page to static file
  def write_file
    # if self.dirty?
      self.generate
      File.delete self.absolute_path if File.exists? self.absolute_path
      File.open(self.absolute_path, 'w+') do |f| 
        f.write(self.generated_header)
        f.write(self.content)
      end
    #   self.not_dirty
    # end
  end
  
  # =====
  #
  # Header and content generation
  #
  # =====
  
  def generate
    self.generate_header
    #self.not_dirty
  end
  
  # Generate YAML header from current page eader and its children
  def generate_header
    self.reload
    self.headers.reload
    
    # Default header values
    yaml_headers = {}
                        
    self.headers.each do |header|
      yaml_headers[header.name] = header.content
    end
    
    update_attributes(:generated_header => YAML::dump(yaml_headers) + "---\n")
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
  # Dirty
  #
  # =====
  
  # Make this page dirty, it'll force Webby to re-generate page
  def is_dirty
    self.headers.first_or_create(:name => :dirty)
    self.pages.each {|page| page.is_dirty}
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
  # Misc
  #
  # =====
  
  def sanitize_filename(filename)
    filename.strip!
    
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    filename.gsub! /^.*(\\|\/)/, ''

    # Finally, replace all non alphanumeric, underscore or periods with underscore
    filename.gsub! /[^\w\.\-]/, '_'
  end
end
