class Document < ActiveRecord::Base
  include CopyProcess
  
  # has_paper_trail only: [:content]
  belongs_to :site
  has_many :notes, order: 'start_character', dependent: :destroy
  
  validate :document_is_in_valid_format
  validates :content, :presence => true
  
  before_save :remove_windows_lines
  
  def name
    if content.blank?
      'Document'
    else
      content.split(/\n/)[1..3].join(' - ').gsub(/\/\*|\\\*/,'')
    end
  end
  
  def value
    if self.content.blank?
      "/*\nType: \nLayer: \nVariation: \n*/"
    else
      self.content
    end
  end
  
  def document_is_in_valid_format
    p = CopyProcess::Processor.new
    if !p.contains_valid_headers(self.content)
      errors.add(:content, "Headers must be in valid format")
    else
      headers = content.split(/\n/)[1..3].join(' - ').gsub(/\/\*|\\\*/,'')
      site_documents = []
      if self.id
        site_documents = Document.where(["site_id = ? AND id <> ?", self.site_id, self.id])
      else
        site_documents = Document.where(["site_id = ?", self.site_id])
      end
      site_documents.each do |doc|
        if doc.name == headers
          errors.add(:content, "headers are not unique.")
          break
        end
      end
    end
  end
  
  private
  
  def remove_windows_lines
    self.content = self.content.gsub(/\r\n/, "\n")
  end
  
end