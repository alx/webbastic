if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  dependency 'merb-slices', :immediate => true
  Merb::Plugins.add_rakefiles "webbastic/merbtasks", "webbastic/slicetasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :webbastic
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:webbastic][:layout] ||= :webbastic
  
  module Webbastic
    
    # Slice metadata
    self.description = "Webbastic is a Merb slice to manage multiple websites with webby"
    self.version = "1.0.0"
    self.author = "Legodata"
    
    def self.init
    end
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
      require "webbastic/helpers"
      ::Webbastic::Helpers.setup
    end
    
    def self.setup_router(scope)
      ::Webbastic::Router.setup(scope)
    end
    
  end
  
  Webbastic.setup_default_structure!
  use_orm :datamapper

  # Merb dependencies
  merb_version = ">= 1.0.9"
  dependency 'merb-assets',               merb_version
  dependency 'merb-cache',                merb_version
  dependency 'merb-helpers',              merb_version
  dependency 'merb_datamapper',           merb_version
  dependency "merb-mailer",               merb_version
  dependency "merb-auth-core",            merb_version
  dependency "merb-auth-more",            merb_version
  dependency "merb-auth-slice-password",  merb_version
  dependency "merb-param-protection",     merb_version
  dependency "merb-exceptions",           merb_version
  
  # Datamapper dependencies
  dm_version   = ">= 0.9.10"
  dependency "dm-core",           dm_version         
  dependency "dm-aggregates",     dm_version  
  dependency "dm-timestamps",     dm_version
  dependency "dm-is-nested_set",  dm_version
  dependency "dm-is-tree",        dm_version
  
  # Various dependencies
  dependency "do_sqlite3"
  dependency "webby", ">= 0.9.3"
  
  # Slice dependencies
  require "webbastic/router"
  require "webbastic/rack/page_slug"
  
  # stdlib dependencies
  require "tempfile"
  require "yaml"
  
end

module Kernel
  def qualified_const_get(str)
    path = str.to_s.split('::')
    from_root = path[0].empty?
    if from_root
      from_root = []
      path = path[1..-1]
    else
      start_ns = ((Class === self)||(Module === self)) ? self : self.class
      from_root = start_ns.to_s.split('::')
    end
    until from_root.empty?
      begin
        return (from_root+path).inject(Object) { |ns,name| ns.const_get(name) }
      rescue NameError
        from_root.delete_at(-1)
      end
    end
    path.inject(Object) { |ns,name| ns.const_get(name) }
  end
end