class ElementType < ActiveRecord::Base
  validate :uniq_to_site
  has_many :elements, dependent: :destroy, order: "content"
  belongs_to :site
  
  def all_content
    self.elements.collect { |e| e.content }.join('\n')
  end
  
  private
  
  def uniq_to_site
    et = ElementType.where(["site_id = ? AND name = ? AND id <> ?", self.site_id, self.name, self.id])
    if et.size > 0
      errors.add(:name, "must be unique to this site")
    end
  end
end