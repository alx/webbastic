class Webbastic::Widgets < Webbastic::Application

  # GET /widgets
  def index
    @widgets = Webbastic::Widget.all
    display @widgets
  end

  # GET /widgets/:id
  def show
    @widget = Webbastic::Widget.get(params[:id])
    raise NotFound unless @widget
    display @widget
  end

  # GET /widgets/new
  def new
    only_provides :html
    @widget = Webbastic::Widget.new
    display @widget
  end
  
  # GET /widgets/:id/edit
  def edit
    only_provides :html
    @widget = Webbastic::Widget.get(params[:id])
    raise NotFound unless @widget
    @widget.load_module if @widget.module
    display @widget.edit_partial
  end

  # POST /widgets
  def create
    
    if widget = Webbastic::Widget.create(:module => params[:widget])
      
      # Add widget to page if parameter included
      if params[:page_id] && page = Webbastic::Page.first(:id  => params[:page_id])
        page.add_widget widget
      end
      
      redirect url(:webbastic_page, params[:page_id])
    else
      message[:error] = "Widget failed to be created"
      render :new
    end
  end

  # PUT /widgets/:id
  def update
    @widget = Webbastic::Widget.get(params[:id])
    raise NotFound unless @widget
    
    if params[:header]
      @widget.add_header params[:header][:name], params[:header][:content]
    end
    
    if params[:widget] && @widget.update_attributes(params[:widget])
       display @widget, :show
    else
      display @widget, :edit
    end
  end

  # DELETE /widgets/:id
  def destroy
    @widget = Webbastic::Widget.get(params[:id])
    raise NotFound unless @widget
    if @widget.destroy
      redirect resource(:pages)
    else
      raise InternalServerError
    end
  end
end
