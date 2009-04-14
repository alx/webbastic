helpers = Pathname(__FILE__).dirname.expand_path / "helpers"
require helpers / "assets"
require helpers / "content"
require helpers / "export"

module Webbastic
  module Helpers
    def self.setup
      [Assets, Content, Export].each do |helper|
        ::Merb::GlobalHelpers.send(:include, helper)
      end
    end
  end
end