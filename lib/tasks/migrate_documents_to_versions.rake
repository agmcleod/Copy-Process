desc "Migrates document content into the child version model"
task :create_versions => :environment do
  # Destroying all versions
  Version.destroy_all
  documents = Document.all
  documents.each do |document|
    version = Version.new(content: document.content, document_id: document.id)
    puts version.errors[:content]
    
    Version.transaction do
      
      document.active_version = version
      version.save!
      document.versions << version
      document.save!
      puts 'version saved'
    end
  end
end