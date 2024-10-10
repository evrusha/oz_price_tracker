class RemoveColumnLastScrapedAtFromCategoryLinks < ActiveRecord::Migration[7.1]
  def change
    remove_column :category_links, :last_scraped_at, :datetime
  end
end
