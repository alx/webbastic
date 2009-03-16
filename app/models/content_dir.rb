class Webbastic::ContentDir
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  
  belongs_to :site, :class_name => Webbastic::Site
  belongs_to :content_dir, :class_name => Webbastic::ContentDir
  
  has n, :pages, :class_name => Webbastic::Page
  
  is :tree, :order => :id
end
