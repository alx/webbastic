class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :template, Text
  property :path, Text, :default => ""
  property :created_at, DateTime
  
  property :content_dir,    Text, :default => ""
  property :layout_dir,     Text, :default => ""
  property :template_dir,   Text, :default => ""
  property :output_dir,     Text, :default => ""
  
  has n, :pages,    :class_name => Webbastic::Page
  has n, :layouts,  :class_name => Webbastic::Layout
  
  after :save, :create_defaults
  
  before :destroy, :unlink_site
  
  def initialize(options = {})
    
    self.name           = options[:name]            || Merb.root[/\/(.[^\/]*)$/,1] # TODO: elegant regexp for Merb.root folder
    self.template       = options[:template]        || "website"
    self.path           = options[:path]            || File.join(Merb.root, "webby", sanitize_filename(self.name))
    self.content_dir    = options[:content_dir]     || File.join(self.path, "content")
    self.layout_dir     = options[:layout_dir]      || File.join(self.path, "layouts")
    self.template_dir   = options[:template_dir]    || File.join(self.path, "templates")
    self.output_dir     = options[:output_dir]      || File.join(Merb.root, 'public', sanitize_filename(self.name))
    
    # Generate webby app with this site parameters
    Webby::Apps::Generator.new.run [self.template, self.path]
  end
  
  # Create default page and layout after site has been saved
  def create_defaults
    self.layouts.create :name => "default"
    self.pages.create   :name => "index"
  end
  
  def default_layout
    self.layouts.first
  end
  
  #
  # Generate site content base on its structure
  #
  def generate
    
    generate_layouts
    generate_pages
    
    Webby.site.content_dir    = relative_path(self.content_dir)
    Webby.site.layout_dir     = relative_path(self.layout_dir)
    Webby.site.template_dir   = relative_path(self.template_dir)
    Webby.site.output_dir     = relative_path(self.output_dir)
    Webby.site.page_defaults  = {'layout' => File.join(self.default_layout.path),
                                 'directory' => "."}

    # TDB: :rebuild => false
    # A content file can mark itself as dirty by setting the +dirty+ flag to
    # +true+ in the meta-data of the file. This will cause the contenet to
    # always be compiled when the builder is run. Conversely, setting the
    # dirty flag to +false+ will cause the content to never be compiled or
    # copied to the output folder.
    Webby::Builder.run :rebuild => true, :verbose => true
    return true
  end

  def generate_layouts
    self.layouts.each do |layout|
      Merb.logger.info "==== Write layout: #{layout.name}"
      layout.write_file
    end
  end
  
  def generate_pages
    self.pages.each do |page|
      Merb.logger.info "==== Write page: #{page.name}"
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
    
    def relative_path(dir)
      Pathname.new(dir).relative_path_from(Pathname.new(Merb.root))
    end
  
  
end
