class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :template, String
  property :path, String
  property :destination, String
  property :created_at, DateTime
  
  has n, :pages,    :class_name => Webbastic::Page
  has n, :layouts,  :class_name => Webbastic::Layout
  
  before :destroy, :unlink_site
  
  def initialize(options = {})
    # Create webby layout for this site
    if options[:name]
      self.name = options[:name]
      self.template = options[:template] || "website"
      self.path = File.join(Merb.root, "webby", options[:name])
      
      Webby::Apps::Generator.new.run [self.template, self.path]
    end
    
  end
  
  #
  # Generate site content base on its structure
  #
  def generate
    
    generate_pages
    
    Webby.site.content_dir    = File.join("webby", self.name, "content")
    Webby.site.layout_dir     = File.join("webby", self.name, "layouts")
    Webby.site.template_dir   = File.join("webby", self.name, "templates")
    Webby.site.output_dir     = self.destination || File.join(Merb.root, 'public', self.name)
    Webby.site.page_defaults  = {'layout' => File.join("webby", self.name, "layouts", "default"),
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
