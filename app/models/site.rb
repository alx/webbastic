class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :created_at, DateTime
  
  has n, :pages,  :class_name => Webbastic::Page
  has n, :layouts,  :class_name => Webbastic::Layout
  has n, :folders,  :class_name => Webbastic::ContentDir
  
  after :create, :create_defaults
  
  before :destroy, :unlink_site
  
  # =====
  #
  # Site creation
  #
  # =====
  
  def initialize(options = {})
    
    # TODO: elegant regexp for Merb.root folder
    self.name = options[:name] || sanitize_filename(Merb.root[/\/(.[^\/]*)$/,1]) 
    
    # Generate webby app with this site parameters
    # use --force to rewrite website (avoid console prompt on overwrite)
    Webby::Apps::Generator.new.run ["--force",                      # options
                                    "website",                      # template
                                    File.join("webby", self.name)]  # path
  end
  
  # Create default page and layout after site has been saved
  def create_defaults
    import_layout(self.layout_dir(:absolute => true))
    import_content(self.content_dir(:absolute => true))
  end
  
  def import_layout(directory)
    Dir.new(directory).each do |path|
      @layout = self.layouts.create :name => path
      
      # Add file content as layout content that could be modified later
      File.open(File.join(directory, path), "r") do |file|
        @layout.content file.read
      end
    end
  end
  
  # Follow directory path and import its files into DB
  def import_content(directory, parent_folder = nil)
    Dir.new(directory).each do |path|
      next if path.match(/^\.+/)
      
      # Create a new Webbastic::ContentDir object for every folders
      if FileTest.directory?(File.join(directory, path))
        if parent_folder
          @folder = parent_folder.children.create :name => path
        else
          @folder = self.folders.create :name => path
        end
        import_content(File.join(directory, path), @folder)
        
      # Create a new Webbastic::Page object for every files
      # and read its content to put it in a static widget
      else
        if parent_folder
          @page = parent_folder.pages.create :name => path
        else
          @page = self.pages.create :name => path
        end
        
        # Add file content as page static content that could be modified later
        File.open(File.join(directory, path), "r") do |file|
          @page.add_static_content file.read
        end
        
      end
    end
  end
  
  # =====
  #
  # Site generate
  #
  # =====
  
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
  
  # =====
  #
  # Site path
  #
  # =====
  
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
    webby_path =  options[:absolute] ? self.absolute_path  : self.relative_path
    
    # options[:dir] contains the name of the folder to fetch
    options[:dir].nil? ? webby_path : File.join(webby_path, options[:dir])
  end
  
  def absolute_path
    if File.symlink? Merb.root
      # Symlink is used in Capistrano, go fetch webby content in shared dir
      File.join(Merb.root, "..", "..", "shared", self.relative_path)
    else
      File.join(Merb.root, self.relative_path)
    end
  end
  
  def relative_path
    File.join("webby", self.name)
  end
  
  # =====
  #
  # Misc
  #
  # =====
  
  def default_layout
    self.layouts.first
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
