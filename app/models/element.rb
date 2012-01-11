class Element < ActiveRecord::Base
  belongs_to :element_type
  
  before_save :set_content_if_nil
  
  def element_type_name
    self.element_type.name
  end
  
  def self.search_by_content(site_id, params)
    if params[:case_sensitive] == "1"
      where(["element_types.site_id = ? AND BINARY elements.content LIKE ?", site_id, "%#{params[:search]}%"]).includes(:element_type)
    else
      where(["element_types.site_id = ? AND UPPER(elements.content) LIKE ?", site_id, "%#{params[:search].upcase}%"]).includes(:element_type)
    end
  end
  
  def set_content_if_nil
    self.content ||= ''
    true
  end
end
