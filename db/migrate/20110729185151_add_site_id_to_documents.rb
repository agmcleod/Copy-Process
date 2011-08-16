class AddSiteIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :site_id, :integer
  end
end
