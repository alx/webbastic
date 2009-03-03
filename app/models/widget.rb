class Webbastic::Widget
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :content, Text
  property :created_at, DateTime
  
  has n, :headers,  :class_name => Webbastic::Header
  
  belongs_to :page, :class_name => Webbastic::Page
  
  is :nested_set, :scope => [:page_id]
  
  after :create, :default_values
  
  def default_values
    default_headers
    default_content
  end
  
  def default_headers
    self.widget_headers.each do |key, value|
      ::Webbastic::Header.create :key => key,
                                 :value => value,
                                 :widget_id => self.id
    end
  end
  
  def default_content
    self.update_attributes :content => self.widget_content
  end
  
  def widget_headers
    []
  end
  
  def widget_content
    ""
  end
end
