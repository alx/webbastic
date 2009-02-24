class Webbastic::Pages < Webbastic::Application
  
  # GET /pages
  def index
    @pages = Webbastic::Page.all
    display @pages
  end

  # GET /pages/:id
  def show
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    display @page
  end

  # GET /pages/new
  def new
    only_provides :html
    @page = Webbastic::Page.new
    display @page
  end
  
  # GET /pages/:id/edit
  def edit
    only_provides :html
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    display @page
  end

  # POST /pages
  def create
    @page = Webbastic::Page.new(params[:page])
    if @page.save
      redirect url(:webbastic_site, @page.site.id)
    else
      message[:error] = "Page failed to be created"
      render :new
    end
  end

  # PUT /pages/:id
  def update(id, page)
    @page = Webbastic::Page.get(id)
    raise NotFound unless @page
    if @page.update_attributes(page)
       redirect resource(@page)
    else
      display @page, :edit
    end
  end

  # DELETE /pages/:id
  def destroy
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    if @page.destroy
      redirect resource(:pages)
    else
      raise InternalServerError
    end
  end
end
