require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Webbastic::Site do

  it "should create a new webby directory" do
    @site = Webbastic::Site.new :name => "test"
    
    # Verify attributes
    @site.should_not be(nil)
    @site.path.should_not be(nil)
    @site.template.should == "website"
    
    # Verify site has been created
    path = File.join( File.dirname(__FILE__), '..', '..', "webby", 'test' )
    File.exists?(path).should == true
    
    @site.destroy
  end
  
  it "should be named as Merb root folder name if option name not specified" do
    @site = Webbastic::Site.new
    @site.name.should == "webbastic"
  end
  
  it "should be named with :name option" do
    @site = Webbastic::Site.new :name => "test"
    @site.name.should == "test"
  end
  
  it "should save site in database" do
    @site = Webbastic::Site.new :name => "test"
    
    @site.save
    site_id = @site.id
    
    # Verify attributes
    @saved = Webbastic::Site.first :id => site_id
    
    @saved.should_not be(nil)
    @saved.path.should_not be(nil)
    @saved.name.should == "test"
    @saved.template.should == "website"
    
    @site.destroy
  end
  
  
  it "should remove files on destroy" do
    @site = Webbastic::Site.new :name => "test"
    @site.destroy
    
    # Verify site has been destroy
    path = File.join( File.dirname(__FILE__), '..', '..', "webby", 'test' )
    File.exists?(path).should == false
  end
  
  it "should contains pages" do
    @site = Webbastic::Site.new :name => "test"
    @site.pages << Webbastic::Page.new(:name => "home")
    
    @site.pages.size.should == 1
    @site.pages.first.name.should == "home"
    
    @site.destroy
  end
  
  it "should generate website" do
    @site = Webbastic::Site.create :name => "test"
    @page = @site.pages.build :name => "home"
    @widget = @page.widgets.build :name => "home", :content => Time.now
    
    @site.generate
    
    path = File.join( File.dirname(__FILE__), '..', '..', "public", 'test', 'home.html' )
    File.exists?(path).should == true
    
    @site.destroy
  end
  
  it "shoud have a default page and layout" do
    @site = Webbastic::Site.create :name => "test"
    
    @site.pages.size.should == 1
    @site.layouts.size.should == 1
    
    layout = @site.default_layout
    layout.kind_of?(Webbastic::Layout).should be(true)
    layout.site.id.should == @site.id
    
    @site.destroy
  end

end