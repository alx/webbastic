class Webbastic::Header
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :value, Text
  property :created_at, DateTime
  
  is :tree, :order => name
  
  belongs_to :page, :class_name => "Webbastic::Page"
end
