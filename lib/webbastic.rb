if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  dependency 'merb-slices', :immediate => true
  Merb::Plugins.add_rakefiles "webbastic/merbtasks", "webbastic/slicetasks", "webbastic/spectasks"

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
  dependency 'merb-assets',     merb_version
  dependency 'merb-cache',     merb_version
  dependency 'merb-helpers',    merb_version
  dependency 'merb_datamapper', merb_version
  
  # Datamapper dependencies
  dm_gems_version   = ">= 0.9.10"
  dependency "dm-core",           dm_gems_version         
  dependency "dm-aggregates",     dm_gems_version  
  dependency "dm-timestamps",     dm_gems_version
  dependency "dm-is-nested_set",  dm_gems_version
  dependency "dm-is-tree",        dm_gems_version
  
  # Various dependencies
  dependency "do_sqlite3"
  dependency "webby", ">= 0.9.3"
  
  # Slice dependencies
  require "webbastic/router"
  require "webbastic/helpers"
  
  # stdlib dependencies
  require "tempfile"
  require "yaml"
  
end