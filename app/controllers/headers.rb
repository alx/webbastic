class Webbastic::Headers < Webbastic::Application

  # PUT /headers/:id
  def update
    @header = Webbastic::Header.get(params[:id])
    raise NotFound unless @header
    @header.update_attributes(params[:header])
    params[:header][:content]
  end

  # DELETE /headers/:id
  def destroy
    @header = Webbastic::Header.get(params[:id])
    raise NotFound unless @header
    if @header.destroy
      display false
    else
      raise InternalServerError
    end
  end
end
