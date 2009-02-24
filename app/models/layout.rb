class Webbastic::Layout
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :created_at, DateTime
  
  belongs_to :page, :class_name => Webbastic::Page
  
  # Write generated page to static file
  def write_layout_file(path)
    File.open File.join(path, "layouts", self.name + ".txt"), "w+" do |f|
      f.write(generated_header)
      f.write(generated_content)
    end # File.open
  end
end
