class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :template, String
  property :path, String
  property :created_at, DateTime
  
  property :content_dir, String
  property :layout_dir, String
  property :template_dir, String
  property :output_dir, String
  property :default_layout, String
  
  has n, :pages,    :class_name => Webbastic::Page
  has n, :layouts,  :class_name => Webbastic::Layout
  
  before :destroy, :unlink_site
  
  def initialize(options = {})
    # Create webby layout for this site
    if options[:name]
      self.name = options[:name]
      self.template = options[:template] || "website"
      self.path = File.join(Merb.root, "webby", options[:name])
      
      self.content_dir    = options[:content_dir]     || File.join("webby", self.name, "content")
      self.layout_dir     = options[:layout_dir]      || File.join("webby", self.name, "layouts")
      self.template_dir   = options[:template_dir]    || File.join("webby", self.name, "templates")
      self.output_dir     = options[:output_dir]      || File.join(Merb.root, 'public', self.name)
      self.default_layout = options[:default_layout]  || File.join("webby", self.name, "layouts", "default")
      
      Webby::Apps::Generator.new.run [self.template, self.path]
    end
    
  end
  
  #
  # Generate site content base on its structure
  #
  def generate
    
    generate_pages
    
    Webby.site.content_dir    = self.content_dir
    Webby.site.layout_dir     = self.layout_dir
    Webby.site.template_dir   = self.template_dir
    Webby.site.output_dir     = self.output_dir
    Webby.site.page_defaults  = {'layout' => self.default_layout,
                                 'directory' => "."}

    Webby::Builder.run
  end
  
  def generate_pages
    self.pages.each do |page|
      page.generate
      page.write_page_file
    end
  end
  
  def status
    "generated"
  end
  
  #
  # When destroying a site,
  # be sure to delete the webby folder that's been created on initialization
  #
  def unlink_site
    if self.path and File.exists?(self.path)
      FileUtils.rm_rf self.path
    end
  end
  
end
