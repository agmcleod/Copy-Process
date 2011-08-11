class ElementTypesController < ApplicationController
  def index
    @site = Site.find(params[:site_id])
    @element_types = ElementType.where(site_id: @site.id)
  end
  
  def show
    @site = Site.find(params[:site_id])
    @element_type = ElementType.find(params[:id])
  end
end
