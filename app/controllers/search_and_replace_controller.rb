class SearchAndReplaceController < ApplicationController
  def new
    @site = Site.find(params[:site_id])
  end
  
  def create
    @site = Site.find(params[:site_id])
    if params[:search].blank?
      redirect_to new_site_search_and_replace_url(@site), notice: 'Content not found.'
    else
      @element_results = Element.search_by_content(@site.id, params)
    end
  end
end