require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Webbastic::Site do

  it "should create a new webby directory" do
    @site = Webbastic::Site.new :name => "test"
    
    # Verify site has been created
    path = File.join( File.dirname(__FILE__), '..', '..', "webby", 'test' )
    File.exists?(path).should == true
    
    @site.destroy
  end
  
  it "should have correct path" do
    @site = Webbastic::Site.new :name => "test"
    
    # Verify relative path
    @site.relative_path.should  == "webby/test"
    @site.content_dir.should    == "webby/test/content"
    @site.layout_dir.should     == "webby/test/layouts"
    @site.template_dir.should   == "webby/test/templates"
    
    # Verify absolute path
    absolute_path = Merb.root
    @site.absolute_path.should  == File.join(absolute_path, "webby/test")
    @site.content_dir(:absolute => true).should    == File.join(absolute_path, "webby/test/content")
    @site.layout_dir(:absolute => true).should     == File.join(absolute_path, "webby/test/layouts")
    @site.template_dir(:absolute => true).should   == File.join(absolute_path, "webby/test/templates")
    
    @site.destroy
  end
  
  it "should be named as Merb root folder name if option name not specified" do
    @site = Webbastic::Site.new
    @site.name.should == "webbastic"
    @site.destroy
  end
  
  it "should be named with :name option" do
    @site = Webbastic::Site.new :name => "test"
    @site.name.should == "test"
    @site.destroy
  end
  
  it "should save site in database" do
    @site = Webbastic::Site.create :name => "test"
    
    site_id = @site.id
    
    # Verify attributes
    @saved = Webbastic::Site.first :id => site_id
    
    @saved.should_not be(nil)
    @saved.name.should == "test"
    
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
    @site = Webbastic::Site.create :name => "test"
    
    @site.pages.size.should == 1
    @site.pages.first.name.should == "index"
    
    @site.pages.create :name => "home"
    @site.pages.size.should == 2
    
    @site.destroy
  end
  
  it "should generate website" do
    @site = Webbastic::Site.create :name => "test"
    @page = @site.pages.create :name => "home"
    @widget = @page.widgets.create :name => "home", :content => Time.now
    
    @site.generate
    
    path = File.join( File.dirname(__FILE__), '..', '..', "public", 'home.html' )
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
  
  it "should generate website each time a widget is modified" do
    @site = Webbastic::Site.create :name => "test"
    @site.pages.create :name => "home"
    
    @site.generate
    
    index_path = File.join( File.dirname(__FILE__), '..', '..', "public", 'index.html' )
    home_path = File.join( File.dirname(__FILE__), '..', '..', "public", 'home.html' )
    
    File.exists?(index_path).should == true
    File.exists?(home_path).should == true
    
    index_size = index_path.size
    home_size = home_path.size
    
    @site.pages.first.add_static_content "long string to modify file size"
    
    index_path.size.should >= index_size
    home_path.size.should == home_size
    
    @site.destroy
  end

end