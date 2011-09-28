class SearchAndReplaceController < ApplicationController
  def new
    @site = Site.find(params[:site_id])
  end
  
  def create
    @site = Site.find(params[:site_id])
    if params[:search].blank?
      nothing_found(@site.id)
    else
      @element_results = Element.search_by_content(@site.id, params)
      if @element_results.size == 0
        nothing_found(@site.id)
      end
    end
  end
  
  private
  
  def nothing_found(site)
    redirect_to new_site_search_and_replace_url(site), notice: 'Content not found.'
  end
end