class AddActiveVersionIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :active_version_id, :integer
  end
end
