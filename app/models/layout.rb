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
  belongs_to :page, :class_name => Webbastic::Page
  
  has n, :headers, :class_name => Webbastic::Header
  
  def path
    File.join(self.site.layout_dir, self.name + ".txt")
  end
  
  # Write generated page to static file
  def write_file
    self.generate_header
    # Write generated page to static file
    File.open self.path, "w+" do |f|
      f.write(self.generated_header)
      f.write(self.content)
    end # File.open
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
    Merb.logger.info "generated_header: #{self.generated_header}"
  end
  
  def header_content(header_name)
    if header = self.headers.first(:name => header_name)
      return header.content
    end
  end
end
