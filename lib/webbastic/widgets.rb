widgets = Pathname(__FILE__).dirname.expand_path / "widgets"
require widgets / "header"

module Webbastic
  module WidgetHelper
    def self.setup
      [HeaderWidget].each do |widget|
        ::Merb::GlobalHelpers.send(:include, widget)
      end
    end
  end
end