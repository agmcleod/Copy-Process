class Document < ActiveRecord::Base
  include CopyProcess
  
  belongs_to :site
  has_many :notes, order: 'start_character'
  
  validate :document_is_in_valid_format
  validates :content, :presence => true
  
  before_create :remove_windows_lines
  
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
  
  def self.test_data
    "/*\n" +
    "Type: Recycling\n" +
    "Layer: State\n" +
    "Variation: 2\n" +
    "*/\n" +
    "HEADER: A second recycling header.\n" +
    "BODY: Recycling sentence one, again - recycling. A second sentence about\n" +
    "recycling, i think. A third sentence about recycling. A fouth sentence about \n" +
    "recycling.\n" +
    "CTA: A call to action - important.\n" +
    "BODY: Recycling sentence* onesise. A second sentence about\n" +
    "recycling. A third sentence about recycling?* A follow up sentence\n" +
    "FOOTER: Some sort of footer\n" +
    "CTA2: A second call to action\n"
  end
  
  def self.bad_test_data
    "HEADER: A second recycling header.\n" +
    "BODY: Recycling sentence one, again. A second sentence about\n" +
    "recycling, i think. A third sentence about recycling. A fouth sentence about \n" +
    "recycling.\n" +
    "CTA: A call to action - important.\n" +
    "BODY: Recycling sentence* onesise. A second sentence about\n" +
    "recycling. A third sentence about recycling?* A follow up sentence\n" +
    "FOOTER: Some sort of footer\n" +
    "CTA2: A second call to action\n"
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