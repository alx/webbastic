helpers = Pathname(__FILE__).dirname.expand_path / "helpers"
require helpers / "assets"
require helpers / "widgets"

module Webbastic
  module Helpers
    def self.setup
      [Assets, Widgets].each do |helper|
        ::Merb::GlobalHelpers.send(:include, helper)
      end
    end
  end
end