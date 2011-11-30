class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.integer :document_id
      t.text :content

      t.timestamps
    end
  end
end
