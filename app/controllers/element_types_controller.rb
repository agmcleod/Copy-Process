class ElementTypesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @site = Site.find(params[:site_id])
    @element_types = ElementType.where(:site_id => @site.id)
  end
  
  def show
    @site = Site.find(params[:site_id])
    @element_type = ElementType.find(params[:id])
  end
  
  def destroy
    @site = Site.find(params[:site_id])
    @element_type = ElementType.find(params[:id])
    @element_type.destroy
    redirect_to site_element_types_url(@site)
  end
  
  def edit
    @site = Site.find(params[:site_id])
    @element_type = ElementType.find(params[:id])
  end
end
