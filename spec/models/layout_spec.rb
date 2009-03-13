require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Webbastic::Layout do

  it "should belong to a site" do
    @site = Webbastic::Site.create :name => "test"
    
    layout = @site.layouts.first
    layout.kind_of?(Webbastic::Layout).should be(true)
    layout.site_id.should == @site.id
    
    @site.destroy
  end
  
  it "should be associated to many pages" do
    @site = Webbastic::Site.create :name => "test"
    @page1 = @site.pages.create :name => "home"
    @page2 = @site.pages.create :name => "archive"

    default_layout = @site.layouts.first
    @page1.layout.id.should == default_layout.id
    @page2.layout.id.should == default_layout.id
    @page1.layout.id.should == @page2.layout.id
    
    @site.destroy
  end

end