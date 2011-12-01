class Version < ActiveRecord::Base
  belongs_to :document
  has_many :notes, order: 'start_character', dependent: :destroy
  
  after_validation :add_validations_to_parent
  
  validate :content_is_in_valid_format
  
  def site_id
    self.document.site_id
  end
  
  def name
    if content.blank?
      'Document'
    else
      content.split(/\n/)[1..3].join(' - ').gsub(/\/\*|\\\*/,'')
    end
  end
  
  private
  
  def content_is_in_valid_format
    p = CopyProcess::Processor.new
    if !p.contains_valid_headers(self.content)
      errors.add(:content, "Headers must be in valid format")
    else
      headers = content.split(/\n/)[1..3].join(' - ').gsub(/\/\*|\\\*/,'')
      site_documents = []
      # Rails.logger.debug("Site id: #{self.site_id} Doc id: #{self.id}")
      if self.document_id
        site_documents = Document.where(["site_id = ? AND id <> ?", self.site_id, self.document_id])
      else
        site_documents = Document.where(["site_id = ?", self.site_id])
      end
      site_documents.each do |doc|
        doc.versions.each do |version|
          if version.name == headers
            errors.add(:content, "headers are not unique.")
            break
          end
        end
      end
    end
  end
  
  
  def add_validations_to_parent
    errors.each do |k, v|
      self.document.errors[:base] << "#{k.to_s.capitalize} #{v}"
    end
  end
end
