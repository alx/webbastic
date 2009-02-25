class Webbastic::Layout
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :created_at, DateTime
  
  belongs_to :site, :class_name => Webbastic::Site
  belongs_to :page, :class_name => Webbastic::Page
  
  has n, :headers, :class_name => Webbastic::Header
  
  after :create, :default_headers
  
  # Write generated page to static file
  def write_layout_file(path)
    File.open File.join(path, "layouts", self.name + ".txt"), "w+" do |f|
      f.write(generated_header)
      f.write(generated_content)
    end # File.open
  end
  
end
