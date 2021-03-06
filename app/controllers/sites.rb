class Webbastic::Sites < Webbastic::Application
  
  # GET /sites
  def index
    @sites = Webbastic::Site.all
    display @sites
  end

  # GET /sites/:id
  def show
    @site = Webbastic::Site.get(params[:id])
    raise NotFound unless @site
    redirect slice_url(:site_pages, @site)
  end

  # GET /sites/new
  def new
    only_provides :html
    @site = Webbastic::Site.new
    display @site
  end
  
  # GET /sites/:id/edit
  def edit
    only_provides :html
    @site = Webbastic::Site.get(params[:id])
    raise NotFound unless @site
    display @site
  end

  # POST /sites
  def create
    @site = Webbastic::Site.new(params[:site])
    if @site.save
      redirect url(:webbastic_site, @site)
    else
      message[:error] = "Site failed to be created"
      render :new
    end
  end

  # PUT /sites/:id
  def update
    @site = Webbastic::Site.get(params[:id])
    raise NotFound unless @site
    
    if params[:default_layout]
      @site.update_attributes :default_layout => Webbastic::Layout.first(:id => params[:default_layout])
      redirect url(:webbastic_site, @site)
    elsif params[:site]
      @site.update_attributes(params[:site])
      redirect url(:webbastic_site, @site)
    else
      display @site, :edit
    end
  end

  # DELETE /sites/:id
  def destroy
    @site = Webbastic::Site.get(params[:id])
    raise NotFound unless @site
    if @site.destroy
      redirect resource(:sites)
    else
      raise InternalServerError
    end
  end
  
  # GET /sites/:id/delete
  def delete
    @site = Webbastic::Site.get(params[:id])
    raise NotFound unless @site
    if @site.destroy
      redirect url(:webbastic_sites)
    else
      raise InternalServerError
    end
  end
  
  def generate
    @site = Webbastic::Site.get(params[:id])
    raise NotFound unless @site
    
    # Webby builder return nil if sucess
    if @site.generate.nil?
      redirect url(:webbastic_site, @site)
    else
      raise InternalServerError
    end
  end
  
  # GET /sites/:id/content
  def content
    if params[:dir] && !params[:dir].empty?
      folder_id = params[:dir].split("/")[1]
      content = Webbastic::ContentDir.first(:id  => folder_id)
      @content = {:folders => content.children, :pages => content.pages}
    else
      @site = Webbastic::Site.get(params[:id])
      raise NotFound unless @site
      @content = {:folders => @site.folders, :pages => @site.pages}
    end
    display @content, :layout => false
  end
  
end
