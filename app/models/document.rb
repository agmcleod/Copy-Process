class Document < ActiveRecord::Base
  include CopyProcess

  belongs_to :site
  has_many :versions, before_add: :set_version_parent
  belongs_to :active_version, class_name: "Version", foreign_key: "active_version_id"
  
  accepts_nested_attributes_for :versions

  validates_associated :versions, :active_version
  # validates_presence_of :active_version
  
  # validate :document_is_in_valid_format
  # validates :content, :presence => true
  
  before_create :set_active_version
  before_save :remove_windows_lines
  
  def name
    # self.active_version.name
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
  
  def active_version_object
    self.active_version || self.versions.first
  end
  
  def content
    self.active_version_object.content
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
  
  def set_active_version
    self.active_version = self.versions.first
  end
  
  def set_version_parent(child)
    child.document ||= self
  end
  
end