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
    
    path = File.join( File.dirname(__FILE__), '..', '..', 'webby', 'test', 'content', 'home' )
    File.exists?(path).should == true
  end
  
  it "should have a header by default" do
    @page = Webbastic::Page.new :name => "home"
    @page.generate_header
    
    header = YAML.load(@page.generated_header)
    header.size.should == 3
    header[:title].should == "home"
  end
  
  it "should have widgets"

end