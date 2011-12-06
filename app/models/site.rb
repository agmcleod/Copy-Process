class Site < ActiveRecord::Base
  include CopyProcess
  
  validates :name, :presence => true
  has_many :documents, :dependent => :destroy
  has_many :element_types, :dependent => :destroy
  
  def to_csv(with_parents)
    p = CopyProcess::Processor.new
    p.compile_files_to_csv(self, with_parents)
  end
  
  def compile_to_save
    Rails.logger.debug("site.compile_to_save")
    # Destroy all existing
    self.element_types.destroy_all
    # build new
    files = []
    p = prepare_documents(files)
    p.compile_files_to_element_types(files, self)
  end
  
  def tokens
    tokens_to_hash(scan_elements(/\[[a-zA-Z]+\]/))
  end
  
  def scan_elements(regex)
    content = ''
    self.element_types.each do |et|
      content << et.all_content
    end
    content.scan(regex)
  end
  
  def active_tokens
    tokens_to_hash(scan_elements(/\$\{[a-zA-Z]+\.[a-zA-Z]+\}/))
  end
  
  def documents_by_name
    docs = {}
    documents.each do |d|
      docs[d.name] = d
    end
    docs.sort{ |a, b| a[0]<=>b[0] }
  end
  
  private
  
  def prepare_documents(files)
    p = CopyProcess::Processor.new
    self.documents.each do |doc|
      Rails.logger.debug "Parsing: #{doc.name}"
      p.parse_each_document(doc.content, files)
    end
    p
  end
  
  def tokens_to_hash(found)
    tokens = {}
    found.each do |f|
      if tokens[f]
        l = tokens[f][1]
        tokens[f] = [f, l + 1]
      else
        tokens[f] = [f, 1]
      end
    end
    tokens
  end
end