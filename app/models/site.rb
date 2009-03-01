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
      
      self.template       = options[:template]        || "website"
      self.path           = options[:path]            || File.join(Merb.root, "webby", sanitize_filename(self.name))
      self.content_dir    = options[:content_dir]     || File.join(self.path, "content")
      self.layout_dir     = options[:layout_dir]      || File.join(self.path, "layouts")
      self.template_dir   = options[:template_dir]    || File.join(self.path, "templates")
      self.default_layout = options[:default_layout]  || "default.txt"
      self.output_dir     = options[:output_dir]      || File.join(Merb.root, 'public', sanitize_filename(self.name))
      
      Webby::Apps::Generator.new.run [self.template, self.path]
    end
    
  end
  
  #
  # Generate site content base on its structure
  #
  def generate
    
    generate_pages
    
    Webby.site.content_dir    = Pathname.new(self.content_dir).relative_path_from(Pathname.new(Merb.root))
    Webby.site.layout_dir     = Pathname.new(self.layout_dir).relative_path_from(Pathname.new(Merb.root))
    Webby.site.template_dir   = Pathname.new(self.template_dir).relative_path_from(Pathname.new(Merb.root))
    Webby.site.output_dir     = Pathname.new(self.output_dir).relative_path_from(Pathname.new(Merb.root))
    Webby.site.page_defaults  = {'layout' => File.join(Webby.site.layout_dir, self.default_layout),
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
  
  protected
  
    def sanitize_filename(filename)
      filename.strip do |name|
        # NOTE: File.basename doesn't work right with Windows paths on Unix
        # get only the filename, not the whole path
        name.gsub! /^.*(\\|\/)/, ''

        # Finally, replace all non alphanumeric, underscore or periods with underscore
        name.gsub! /[^\w\.\-]/, '_'
      end
    end
  
  
end
