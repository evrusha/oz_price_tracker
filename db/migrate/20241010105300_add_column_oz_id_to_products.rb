class AddColumnOzIdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :oz_id, :bigint, null: false
  end
end
