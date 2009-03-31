class Webbastic::ContentDir
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  
  belongs_to :site,         :class_name => Webbastic::Site,       :child_key => [:site_id]
  belongs_to :content_dir,  :class_name => Webbastic::ContentDir, :child_key => [:content_dir_id]
  
  has n, :pages, :class_name => Webbastic::Page
  
  is :tree, :order => :id
end
