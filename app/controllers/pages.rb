class Webbastic::Pages < Webbastic::Application
  
  # GET /pages
  def index
    @pages = Webbastic::Page.all :site_id => params[:site_id]
    @pages = @pages.select do |page| 
      header = page.header_content("admin_page_show")
      header.nil? || header != "false"
    end
    display @pages
  end

  # GET /pages/:id
  def show
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    display @page, :edit
  end

  # GET /pages/new
  def new
    only_provides :html
    @page = Webbastic::Page.new
    #display @page
    render :static
  end
  
  # GET /pages/:id/edit
  def edit
    only_provides :html
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    display @page
  end
  
  # GET /static_pages/:id/edit
  def static
    only_provides :html
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    display @page
  end

  # POST /pages
  def create
    @page = Webbastic::Page.new(params[:page])
    if @page.save
      display @page, :edit
    else
      message[:error] = "Page failed to be created"
      render :new
    end
  end

  # PUT /pages/:id
  def update
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page

    # Update layout
    if params[:layout_id]
      @page.update_attributes :layout_id => params[:layout_id]
    end
    
    # Update headers
    if header = params[:header]
      @page.headers.create header
    end
    
    display @page, :edit
  end

  def delete
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    site = @page.site
    if @page.destroy
      redirect url(:webbastic_site_pages, site)
    else
      raise InternalServerError
    end
  end
end
