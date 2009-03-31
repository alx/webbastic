require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Webbastic::Layout do

  it "should belong to a site" do
    @site = Webbastic::Site.create :name => "test"
    
    layout = @site.layouts.first
    layout.kind_of?(Webbastic::Layout).should be(true)
    layout.site_id.should == @site.id
    
    @site.destroy
  end
  
  it "should be associated to a page" do
    @site = Webbastic::Site.create :name => "test"
    @page1 = @site.pages.create :name => "home"
    @page2 = @site.pages.create :name => "archive"

    @page1.current_layout.id.should == @site.default_layout.id
    @page2.current_layout.id.should == @site.default_layout.id
    
    @layout = @site.layouts.create :name => "new_layout"
    @page1.layout = @layout
    
    @page1.current_layout.id.should_not == @site.default_layout.id
    @page1.current_layout.id.should_not == @page2.current_layout.id
    
    @site.destroy
  end

  it "should be dirty" do
    @site = Webbastic::Site.create :name => "test"
    @page = @site.pages.create :name => "home"
    @layout = @site.default_layout
    
    @page.dirty?.should == true
    @layout.dirty?.should == true
    
    @site.generate
    
    @page.dirty?.should == false
    @layout.dirty?.should == false
    
    @layout.update_attributes :content => "123"
    
    @page.dirty?.should == true
    @layout.dirty?.should == true
    
    @layout.not_dirty
    
    @page.dirty?.should == true
    @layout.dirty?.should == false
    
    @site.destroy
  end

end