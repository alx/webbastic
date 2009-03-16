class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :created_at, DateTime
  
  has n, :pages,  :class_name => Webbastic::Page
  has n, :layouts,  :class_name => Webbastic::Layout
  
  after :create, :create_defaults
  
  before :destroy, :unlink_site
  
  def initialize(options = {})
    
    self.name = options[:name] || Merb.root[/\/(.[^\/]*)$/,1] # TODO: elegant regexp for Merb.root folder
    
    # Generate webby app with this site parameters
    # use --force to rewrite website (avoid console prompt on overwrite)
    Webby::Apps::Generator.new.run ["--force", "website", File.join("webby", sanitize_filename(self.name))]
  end
  
  # Create default page and layout after site has been saved
  def create_defaults
    @layout = self.layouts.create :name => "default"
    self.layouts.reload
    
    @page = self.pages.create :name => "index"
    @page.layout = @layout
  end
  
  def default_layout
    self.layouts.first
  end
  
  #
  # Generate site content base on its structure
  #
  def generate
    
    self.layouts.each {|layout| layout.write_file}
    self.pages.each {|page| page.write_file}
    
    Webby.site.content_dir    = self.content_dir
    Webby.site.layout_dir     = self.layout_dir
    Webby.site.template_dir   = self.template_dir
    Webby.site.output_dir     = File.join(Merb.root, 'public')
    
    # Use directory => '.' option to generate the site in output_dir
    Webby.site.page_defaults  = {'layout' => self.default_layout.relative_path,
                                 'directory' => '.',
                                 'collision' => :force}

    # TDB: :rebuild => false
    # A content file can mark itself as dirty by setting the +dirty+ flag to
    # +true+ in the meta-data of the file. This will cause the contenet to
    # always be compiled when the builder is run. Conversely, setting the
    # dirty flag to +false+ will cause the content to never be compiled or
    # copied to the output folder.
    #
    # returns nil if success 
    Webby::Builder.run(:rebuild => true)
  end
  
  def status
    "generated"
  end
  
  #
  # When destroying a site,
  # be sure to delete the webby folder that's been created on initialization
  #
  def unlink_site
    FileUtils.rm_rf(self.absolute_path) if File.exists?(self.absolute_path)
  end
  
  # =====
  #
  # Site path
  #
  # =====
  
  def relative_path
    File.join("webby", sanitize_filename(self.name))
  end
  
  def absolute_path
    File.join(Merb.root, self.relative_path)
  end
  
  def content_dir(options = {})
    options[:dir] = "content"
    build_webby_path(options)
  end
  
  def layout_dir(options = {})
    options[:dir] = "layouts"
    build_webby_path(options)
  end
  
  def template_dir(options = {})
    options[:dir] = "templates"
    build_webby_path(options)
  end
  
  def build_webby_path(options = {})
    File.join(options[:absolute] ? self.absolute_path : self.relative_path, options[:dir]) unless options[:dir].nil?
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
