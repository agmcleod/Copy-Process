class Site < ActiveRecord::Base
  include CopyProcess
  
  validates :name, presence: true
  has_many :documents, dependent: :destroy
  has_many :element_types, dependent: :destroy
  
  def to_csv
    files = []
    p = prepare_documents(files)
    p.compile_files_to_csv(files)
  end
  
  def compile_to_save
    # Destroy all existing
    self.element_types.destroy_all
    # build new
    files = []
    p = prepare_documents(files)
    p.compile_files_to_element_types(files, self.id)
  end
  
  private
  
  def prepare_documents(files)
    p = CopyProcess::Processor.new
    self.documents.each do |doc|
      p.parse_each_document(doc.content, files)
    end
    p
  end
end