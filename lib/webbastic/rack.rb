module Webbastic
  module Rack
    def self.setup
      Merb::Rack.autoload :PageSlug, 'webbastic/rack/page_slug'
    end
  end
end