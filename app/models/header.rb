class Webbastic::Header
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :value, Text
  
  is :tree, :order => name
  
  belongs_to :page, :class_name => "Webbastic::Page"
  
  # Generate current header and ts children and return result in YAML
  def generate_yaml
  end
end
