class ElementsController < ApplicationController
  def index
    @site = Site.find(params[:site_id])
    @elements = []
    @element_types = ElementType.where(:site_id => params[:site_id])
    if params[:element_type_id]
      @element_type = ElementType.find(params[:element_type_id])
      @elements = ElementType.elements
    else
      # @elements = Element.where(["elements.element_type_id = element_types.id AND element_types.site_id = ?", @site.id]).joins(:element_type)
    end
  end

end
