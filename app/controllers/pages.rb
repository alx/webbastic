class Webbastic::Pages < Webbastic::Application
  
  # GET /pages
  def index
    @pages = Webbastic::Page.all :site_id => params[:site_id]
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
    @widgets = Webbastic::Helpers::Widgets.constants
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
    @layout = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    
    Webbastic::Header.create(params[:header]) if params[:header]
    @page.update_attributes(params[:page]) if params[:page]
    
    display @layout, :edit
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
