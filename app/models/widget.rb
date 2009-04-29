class Webbastic::Widget
  include DataMapper::Resource
  include Merb::GlobalHelpers

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
  # after :update, :page_is_dirty
  
  def default_headers
    if load_module && defined? self.widget_headers
      self.widget_headers.each do |name, content|
        self.headers.create :name => name,
                            :content => content
      end
    end
  end
  
  def generate_content
    if load_module && defined? self.widget_content
      self.update_attributes :content => self.widget_content
    end
  end
  
  def load_module
    self.extend(Webbastic::Helpers::Widgets.full_const_get self.module) if self.module
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
  
  def page_is_dirty
    self.page.is_dirty if self.page
  end
  
  # =====
  #
  # Headers
  #
  # =====
  
  def add_header(name, content)
    if header = self.has_header?(name)
      header.update_attributes(:content => content) unless header.content == content
    else
      header = self.headers.create :name => name,
                                   :content => content
    end
    return header
  end
  
  def header_content(name)
    if header = self.has_header?(name)
      return header.content
    end
  end
  
  def has_header?(name)
    return Webbastic::Header.first(:widget_id => self.id, :name => name)
  end
end
