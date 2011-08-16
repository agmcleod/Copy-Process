class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.text :content
      t.string :note

      t.timestamps
    end
  end
end
