class Webbastic::Site
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :created_at, DateTime
  
  has n, :pages,  :class_name => Webbastic::Page
  has n, :layouts,  :class_name => Webbastic::Layout
  has n, :folders,  :class_name => Webbastic::ContentDir
  has 1, :default_layout, :class_name =>  Webbastic::Layout
  
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
    
    index = File.join("webby", self.name, "content", "index")
    
    unless File.exists? index
      # Generate webby app with this site parameters
      # use --force to rewrite website (avoid console prompt on overwrite)
      Webby::Apps::Generator.new.run ["--force",  # options
                                      "website",  # template
                                      path]       # path
                                      
      # rename index file, without extension
      File.rename "#{index}.txt", index
    end
  end
  
  # Create default page and layout after site has been saved
  def create_defaults
    import_layout(self.layout_dir(:absolute => true))
    import_content(self.content_dir(:absolute => true))
  end
  
  def import_layout(directory)
    Dir.new(directory).each do |path|
      next if path.match(/^\.+/)
      
      @layout = self.layouts.create :name => path
      
      # Add file content as layout content that could be modified later
      File.open(File.join(directory, path), "r") do |file|
        @layout.content = read_content(file.read)
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
          @page = parent_folder.pages.create :name => path, :layout => self.default_layout
        else
          @page = self.pages.create :name => path, :layout => self.default_layout
        end
        
        file = File.new(File.join(directory, path), "r")
        content = ""
        while (line = file.gets)
          content << line
        end
        file.close
        
        @page.add_static_content
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
    #self.layouts.each {|layout| layout.write_file}
    #self.pages.each {|page| page.write_file}
    
    verify_path
    
    Webby.site.content_dir    = self.content_dir :absolute => true
    Webby.site.layout_dir     = self.layout_dir :absolute => true
    Webby.site.template_dir   = self.template_dir
    Webby.site.output_dir     = self.output_dir
    
    Merb.logger.debug "content_dir: #{Webby.site.content_dir}"
    Merb.logger.debug "layout_dir: #{Webby.site.layout_dir}"
    Merb.logger.debug "template_dir: #{Webby.site.template_dir}"
    Merb.logger.debug "output_dir: #{Webby.site.output_dir}"
    
    # Use directory => '.' option to generate the site in output_dir
    Webby.site.page_defaults  = {'layout' => self.default_layout.relative_path,
                                 'directory' => '.',
                                 'collision' => :force}
    
    Merb.logger.debug "page_defaults: #{Webby.site.page_defaults}"                             
    # returns nil if success 
    # Webby::Builder.run
    Webby::Builder.run :rebuild => true
  end
  
  # =====
  #
  # Site path
  #
  # =====
  
  def output_dir(options = {})
    options[:dir] = "generate"
    build_webby_path(options)
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
    webby_path =  options[:absolute] ? self.absolute_path  : self.relative_path
    
    # options[:dir] contains the name of the folder to fetch
    options[:dir].nil? ? webby_path : File.join(webby_path, options[:dir])
  end
  
  def verify_path
    ["generate", "content", "layouts", "templates"].each do |path|
      webby_path = File.join(self.absolute_path, path)
      unless File.exists? webby_path
        FileUtils.mkdir_p webby_path
      end
    end
  end
  
  def verify_capistrano_path
    # If not already done, move webby to shared directory
    unless File.exists? File.join(Merb.root, "..", "..", "shared", self.relative_path)
      webby_current = File.join(Merb.root, "webby")
      webby_shared  = File.join(Merb.root, "..", "..", "shared", "webby")
      
      FileUtils.mv   webby_current, webby_shared
      FileUtils.ln_s webby_shared, webby_current
    end
  end
  
  def absolute_path
    if File.symlink? Merb.root
      verify_capistrano_path
      # Symlink is used in Capistrano, go fetch webby content in shared dir
      File.join(Merb.root, "..", "..", "shared", self.relative_path)
    else
      File.join(Merb.root, self.relative_path)
    end
  end
  
  def relative_path
    File.join("webby", sanitize_filename(self.name))
  end
  
  # =====
  #
  # Misc
  #
  # =====
  
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
  
  # Remove the page headers, return the content of the page
  def read_content(content)
    unless content.empty?
      content.gsub(/-{3}.*-{3}\n/m, '')
    end
  end
  
  # Remove the page content, return the headers
  def read_headers(page_content)
    format = page_content.split("---")
    if format.size > 0
      return YAML.load(format[1])
    else
      return nil
    end
  end
   
  def sanitize_filename(filename)
    sanitized = filename.strip
    
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    sanitized = filename.gsub /^.*(\\|\/)/, ''

    # Finally, replace all non alphanumeric, underscore or periods with underscore
    sanitized = filename.gsub /[^\w\.\-]/, '_'
    
    CGI.escape sanitized
  end
end