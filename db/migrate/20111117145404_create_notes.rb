class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :body
      t.integer :start_character
      t.integer :end_character
      t.string :author

      t.timestamps
    end
  end
end
