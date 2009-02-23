class Webbastic::Main < Webbastic::Application
  
  def index
    @sites = Webbastic::Site.all
    render
  end
  
end