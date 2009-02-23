class Webbastic::Widget
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :created_at, DateTime
  
  belongs_to :page, :class_name => "Webbastic::Page"
  
  is :nested_set, :scope => [:page_id]
end
