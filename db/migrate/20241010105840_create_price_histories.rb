class CreatePriceHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :price_histories do |t|
      t.references :product, null: false, foreign_key: true
      t.float :price_old
      t.float :price_new
      t.datetime :created_at, null: false
    end
  end
end
