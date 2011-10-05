class ElementTypesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @site = Site.find(params[:site_id])
    @element_types = ElementType.where(:site_id => @site.id).order(:name)
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
  
  def update
    @site = Site.find(params[:site_id])
    @element_type = ElementType.find(params[:id])
    if @element_type.update_attributes(params[:element_type])
      redirect_to [@site, @element_type], :notice => 'Element type updated successfully!'
    else
      render :action => 'edit'
    end
  end
end
