class Webbastic::Layouts < Webbastic::Application
  layout :site
  
  # GET /layouts
  def index
    @layouts = Webbastic::Layout.all
    display @layouts
  end

  # GET /layouts/:id
  def show
    @layout = Webbastic::Layout.get(params[:id])
    raise NotFound unless @layout
    display @layout
  end

  # GET /layouts/new
  def new
    only_provides :html
    @layout = Webbastic::Layout.new
    display @layout
  end
  
  # GET /layouts/:id/edit
  def edit
    only_provides :html
    @layout = Webbastic::Layout.get(params[:id])
    raise NotFound unless @layout
    display @layout
  end

  # POST /layouts
  def create
    @layout = Webbastic::Layout.new(params[:widget])
    if @layout.save
      redirect url(:webbastic_layout, @layout.id)
    else
      message[:error] = "Layout failed to be created"
      render :new
    end
  end

  # PUT /layouts/:id
  def update(id, page)
    @layout = Webbastic::Layout.get(id)
    raise NotFound unless @layout
    if @layout.update_attributes(page)
       redirect resource(@layout)
    else
      display @layout, :edit
    end
  end

  # DELETE /layouts/:id
  def destroy
    @layout = Webbastic::Layout.get(params[:id])
    raise NotFound unless @layout
    if @layout.destroy
      redirect resource(:layouts)
    else
      raise InternalServerError
    end
  end
end
