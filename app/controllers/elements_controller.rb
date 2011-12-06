class ElementsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @site = Site.find(params[:site_id])
    @elements = []
    @element_types = ElementType.where(:site_id => params[:site_id]).order(:name)
    if params[:element_type_id]
      @element_type = ElementType.find(params[:element_type_id])
      @elements = ElementType.elements
    end
  end

end
