desc "Migrates document content into the child version model"
task :create_versions => :environment do
  # Destroying all versions
  Version.destroy_all
  documents = Document.includes(:versions)
  documents.each do |document|
    puts document.valid?
    version = Version.new(content: document.content, document_id: document.id)
    puts version.errors[:content]
    
    Version.transaction do
      version.save
      document.active_version_id = version.id
      document.save
      puts 'version saved'
    end
  end
end