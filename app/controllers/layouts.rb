class Webbastic::Layouts < Webbastic::Application
  
  # GET /layouts
  def index
    @layouts = Webbastic::Layout.all :site_id => params[:site_id]
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
    @layout = Webbastic::Layout.new(params[:layout])
    if @layout.save
      display @layout, :edit
    else
      message[:error] = "Layout failed to be created"
      render :new
    end
  end

  # PUT /layouts/:id
  def update
    @layout = Webbastic::Layout.get(params[:id])
    raise NotFound unless @layout
    
    Webbastic::Header.create(params[:header]) if params[:header]
    @layout.update_attributes(params[:layout]) if params[:layout]
    
    display @layout, :edit
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
