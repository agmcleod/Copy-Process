class RenameDocumentIdToVersionId < ActiveRecord::Migration
  def up
    rename_column :notes, :document_id, :version_id
  end

  def down
    rename_column :notes, :version_id, :document_id
  end
end
