class Webbastic::Headers < Webbastic::Application

  # PUT /headers/:id
  def update
    @header = Webbastic::Header.get(params[:id])
    raise NotFound unless @header
    if @header.update_attributes(params[:header])
      true
    else
      false
    end
  end

  # DELETE /headers/:id
  def destroy
    @header = Webbastic::Header.get(params[:id])
    raise NotFound unless @header
    if @header.destroy
      true
    else
      raise InternalServerError
    end
  end
end
