widgets = Pathname(__FILE__).dirname.expand_path / "widgets"
require widgets / "empty"

module Webbastic
  module WidgetHelper
    def self.setup
      [Empty].each do |widget|
        ::Merb::GlobalHelpers.send(:include, widget)
      end
    end
  end
end