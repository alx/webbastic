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
    display @page, :edit
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
  
  # GET /static_pages/:id/edit
  def static
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
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page

    # Update layout
    if params[:layout_id]
      Webbastic::Layout.first(:id => params[:layout_id]).update_attributes(:page_id => @page.id)
    end
    
    # Update widgets
    if params[:page_type] == "static"
      @page.add_static_content params[:page][:content]
      display @page, :static
    else
      @page.update_attributes(params[:page]) if params[:page]
    end
    
    # Update headers
    if params[:page] && params[:page][:headers]
      params[:page][:headers].each do |name, content|
        @page.add_header name, content
      end
    end
    
    display @page, :edit
  end

  def delete
    @page = Webbastic::Page.get(params[:id])
    raise NotFound unless @page
    if @page.destroy
      redirect resource(:pages)
    else
      raise InternalServerError
    end
  end
end
