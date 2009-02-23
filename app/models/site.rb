class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :template, String
  property :path, String
  
  has n, :pages, :class_name => Webbastic::Page
  
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
    self.pages.each do |page|
      page.generate
      page.write_file
      Webby::Builder.create(page.name, :from => page.path)
    end
    Webby.site.base = self.name
    Webby::Builder.run
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
