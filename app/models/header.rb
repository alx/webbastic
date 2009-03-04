class Webbastic::Header
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :created_at, DateTime
  
  is :tree, :order => name
  
  belongs_to :page,   :class_name => Webbastic::Page
  belongs_to :layout, :class_name => Webbastic::Layout
  belongs_to :widget, :class_name => Webbastic::Widget
end
