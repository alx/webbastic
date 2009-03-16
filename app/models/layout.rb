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
  
  belongs_to :site, :class_name => Webbastic::Site
  
  has n, :pages, :class_name => Webbastic::Page
  has n, :headers, :class_name => Webbastic::Header
  
  # =====
  #
  # File Path
  #
  # =====
  
  def relative_path(options = {})
    File.join(self.site.layout_dir(options), self.name)
  end
  
  def absolute_path
    relative_path(:absolute => true)
  end
  
  # Write generated page to static file
  def write_file
    self.generate
    File.delete self.absolute_path if File.exists? self.absolute_path
    File.open(self.absolute_path, 'w+') do |f| 
      f.write(self.generated_header)
      f.write(self.content)
    end
  end
  
  # =====
  #
  # Header and content generation
  #
  # =====
  
  def generate
    self.generate_header
  end
  
  # Generate YAML header from current page eader and its children
  def generate_header
    self.reload
    self.headers.reload
    
    # Default header values
    yaml_headers = { 'extension' => 'html',
                     'filter'    => 'erb' }
                        
    self.headers.each do |header|
      yaml_headers[header.name] = header.content
    end
    
    update_attributes(:generated_header => YAML::dump(yaml_headers) + "---\n")
  end
  
  def header_content(header_name)
    if header = self.headers.first(:name => header_name)
      return header.content
    end
  end
end
