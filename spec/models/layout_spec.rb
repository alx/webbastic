require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Webbastic::Widget do

  it "should belong to a site" do
    @site = Webbastic::Site.create :name => "test"
    
    layout = @site.layouts.first
    layout.should be(Webbastic::Layout)
    layout.site_id.should == @site.id
    
    @site.destroy
  end
  
  it "should be associated to many pages" do
    @site = Webbastic::Site.create :name => "test"
    @site.pages.build :name => "home"
    @site.pages.build :name => "archive"

    default_layout = @site.layouts.first

    @page1.layout.id.should == @page2.layout.id
    
    @site.destroy
  end

end