class CreateElementTypes < ActiveRecord::Migration
  def change
    create_table :element_types do |t|
      t.string :name
      t.integer :site_id

      t.timestamps
    end
  end
end
