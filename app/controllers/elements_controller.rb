class ElementsController < ApplicationController
  def index
    @site = Site.find(params[:site_id])
    @elements = []
    @element_types = ElementType.where(:site_id => params[:site_id])
    if params[:element_type_id]
      @element_type = ElementType.find(params[:element_type_id])
      @elements = ElementType.elements
    end
  end

end
