class AddUrlIndexToCategoryLinks < ActiveRecord::Migration[7.1]
  def change
    add_index :category_links, :url, unique: true
  end
end
