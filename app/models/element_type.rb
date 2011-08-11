class ElementType < ActiveRecord::Base
  validate :uniq_to_site
  has_many :elements, dependent: :destroy
  
  private
  
  def uniq_to_site
    et = ElementType.where(["site_id = ? AND name = ?", self.site_id, self.name])
    if et.size > 0
      errors.add(:name, "must be unique to this site")
    end
  end
end