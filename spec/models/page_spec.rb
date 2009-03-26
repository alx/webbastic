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
    
    @page = @site.pages.create :name => "home"
    
    @page.write_file
    
    path = File.join( @site.content_dir(:absolute => true), 'home' )
    @page.absolute_path.should == path
    File.exists?(path).should == true
  end
  
  it "should have a header by default" do
    @page = Webbastic::Page.new :name => "home"
    @page.generate_header
    
    header = YAML.load(@page.generated_header)
    
    # default header: {'title' => self.name,
    #                 'created_at' => Time.now, 
    #                 'extension' => 'html',
    #                 'filter' => 'erb',
    #                 'layout' => layout}
    header.size.should == 5
    header['title'].should == "home"
  end
  
  it "should have a static widget and have generated content" do
    @page = Webbastic::Page.new :name => "test"
    @page.add_static_content "pop"
    
    @page.widgets.size.should == 1
    @page.widgets.first.content.should == "pop"
    
    @page.generate
    @page.generated_content.should == "pop"
    
    @page.static_widget.content.should == "pop"
  end
  
  it "should be dirty with new content" do
    @page = Webbastic::Page.create :name => "test"
    @page.add_static_content "pop"
    
    @page.is_dirty?.should == true
  end
  
end