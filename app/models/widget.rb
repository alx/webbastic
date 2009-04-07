class Webbastic::Widget
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :content, Text, :default => ""
  property :created_at, DateTime
  property :module, Text, :default => ""
  
  has n, :headers,  :class_name => Webbastic::Header
  
  belongs_to :page, :class_name => Webbastic::Page, :child_key => [:page_id]
  
  is :nested_set, :scope => [:page_id]
  
  after :create, :default_headers
  
  # Add :dirty header to only re-generate this page
  after :update, :page_is_dirty
  after :update, :generate_content
  
  def default_headers
    self.widget_headers.each do |name, content|
      self.headers.create :name => name,
                          :content => content
    end
  end
  
  def generate_content
    self.update_attributes :content => self.widget_content
  end
      
  JS_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"',
    "'"     => "\\'" }
      
  def js_content
    content.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
  end
  
  def header_content(header_name)
    if header = self.headers.first(:name => header_name)
      return header.content
    end
  end
  
  def page_is_dirty
    self.page.is_dirty if self.page
  end
end
