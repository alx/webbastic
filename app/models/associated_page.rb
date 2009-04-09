class Webbastic::AssociatedPage
  include DataMapper::Resource
 
  property :page_id, Integer, :key => true
  property :parent_page_id, Integer, :key => true
 
  belongs_to :page, :class_name => Webbastic::Page, :child_key => [:page_id]
  belongs_to :parent_page, :class_name => Webbastic::Page, :child_key => [:parent_page_id]
end