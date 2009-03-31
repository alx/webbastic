class Webbastic::Header
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :created_at, DateTime
  
  is :tree, :order => name
  
  belongs_to :page,   :class_name => Webbastic::Page,   :child_key => [:page_id]
  belongs_to :layout, :class_name => Webbastic::Layout, :child_key => [:layout_id]
  belongs_to :widget, :class_name => Webbastic::Widget, :child_key => [:widget_id]
end
