class CreateCategoryLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :category_links do |t|
      t.string :url
      t.datetime :last_scraped_at

      t.timestamps
    end
  end
end
