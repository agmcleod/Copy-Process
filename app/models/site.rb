class Site < ActiveRecord::Base
  include CopyProcess
  
  validates :name, presence: true
  has_many :documents
  
  def to_csv
    p = CopyProcess::Processor.new
    files = []
    self.documents.each do |doc|
      p.parse_each_document(doc.content, files)
    end
    p.compile_files_to_csv(files)
  end
end