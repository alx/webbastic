require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Webbastic::Page do

  it "should create a page" do
    @page = Webbastic::Page.new :name => "test"
    @page.name.should == "test"
    @page.generated_content.should == ""
  end
  
  it "should write file with page information" do
    @site = Webbastic::Site.new :name => "test"
    @site.save
    
    @page = Webbastic::Page.new :name => "home", :site_id => @site.id
    @page.save
    
    @page.write_page_file
    
    path = File.join( Merb.root, 'webby', 'test', 'content', 'home' )
    @page.path.should == path
    File.exists?(path).should == true
  end
  
  it "should have a header by default" do
    @page = Webbastic::Page.new :name => "home"
    @page.generate_header
    
    header = YAML.load(@page.generated_header)
    
    # default header: {'title' => self.name, 'created_at' => Time.now}
    header.size.should == 2
    header['title'].should == "home"
  end
  
  it "should have a static widget" do
    @page = Webbastic::Page.new :name => "test"
    @page.add_static_content "pop"
    
    @page.widgets.size.should == 1
    @page.widgets.first.content.should == "pop"
    
    @page.static_widget.content.should == "pop"
  end
end