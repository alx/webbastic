class Webbastic::Page
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :created_at, DateTime
  
  # Generated values are a stored text generated from 
  # the relationship with children objects
  property :generated_header, Text, :default => ""
  property :generated_content, Text, :default => ""
  
  belongs_to :site, :class_name => Webbastic::Site
  
  has n, :headers, :class_name => Webbastic::Header
  has n, :widgets, :class_name => Webbastic::Widget
  
  def generate
    generate_header
    generate_content
  end
  
  def write_file
    # Write generated page to static file
    File.open self.path, "w+" do |f|
      f.write(generated_header)
      f.write(generated_content)
    end # File.open
  end
  
  def path
    File.join(self.site.path, "content", self.name << ".txt")
  end
  
  # Generate YAML header from current page eader and its children
  def generate_header
    # Default header values
    generated_header = {'title' => self.name, 
                        'created_at' => Time.now}
                        # 'destination' => self.site.destination || File.join(Merb.root, 'public', self.site.name)}
    # Child header values
    # generated_header
    update_attributes(:generated_header => YAML::dump(generated_header) + "---\n")
  end
  
  def generate_content
    generated_content = ""
    self.widgets.each do |widget|
      generated_content += (widget.content || "")
    end
    update_attributes(:generated_content => generated_content)
  end
  
end
