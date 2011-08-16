class AddElementTypeIdToElements < ActiveRecord::Migration
  def change
    add_column :elements, :element_type_id, :integer
  end
end
