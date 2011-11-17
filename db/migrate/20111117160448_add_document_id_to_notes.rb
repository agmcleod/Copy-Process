class AddDocumentIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :document_id, :integer
  end
end
