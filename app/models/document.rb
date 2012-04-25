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