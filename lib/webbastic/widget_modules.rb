widgets = Pathname(__FILE__).dirname.expand_path / "widget_modules"
require widgets / "code"
require widgets / "rss"
require widgets / "static"

#if Merb.const_defined? :MediaRocket
  require widgets / "gallery_builder"
  require widgets / "media_list"
#end

module Webbastic
  module WidgetModules
    def self.setup
      [CodeWidget, RssWidget, StaticWidget].each do |widget|
        ::Merb::GlobalHelpers.send(:include, widget)
      end
      
      #if Merb.const_defined? :MediaRocket
        [GalleryBuilderWidget, MediaListWidget].each do |widget|
          ::Merb::GlobalHelpers.send(:include, widget)
        end
      #end
      
    end
  end
end