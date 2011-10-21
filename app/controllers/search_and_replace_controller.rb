class SearchAndReplaceController < ApplicationController
  before_filter :authenticate_user!
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
      elsif !params[:replace].blank?
        case_sensitive = (params[:case_sensitive] == "1")
        @element_results.each do |ele|
          if case_sensitive
            ele.update_attribute(:content, ele.content.gsub("#{params[:search]}", params[:replace]))
          else
            ele.update_attribute(:content, ele.content.gsub(/#{regex_safe(params[:search])}/i, params[:replace]))
          end
        end
      end
    end
  end
  
  private
  
  def nothing_found(site)
    redirect_to new_site_search_and_replace_url(site), :notice => 'Content not found.'
  end
  
  def regex_safe(str)
    str.gsub(/\W+/) { |match| "\\#{match}" }
  end
end