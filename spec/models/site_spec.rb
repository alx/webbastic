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
  
  it "should save site in database" do
    @site = Webbastic::Site.new :name => "test"
    
    @site.save
    
    # Verify attributes
    @saved = Webbastic::Site.first
    
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
    @page = Webbastic::Page.create :name => "home", :site_id => @site.id
    @widget = Webbastic::Widget.create :name => "home", :content => Time.now, :page_id => @page.id
    
    @site.generate
    
    path = File.join( File.dirname(__FILE__), '..', '..', "public", 'test', 'home.html' )
    File.exists?(path).should == true
    
    @site.destroy
  end

end