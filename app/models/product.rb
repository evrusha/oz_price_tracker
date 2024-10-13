class Product < ApplicationRecord
  has_many :price_histories, dependent: :destroy

  scope :average_price_by_date, lambda { |start_date, end_date|
    dates = (start_date..end_date).map do |date|
      "AVG(CASE WHEN DATE(price_histories.created_at) = '#{date}' THEN price_histories.price_new ELSE NULL END)"
    end.join(', ')
    joins(:price_histories)
      .where('DATE(price_histories.created_at) BETWEEN ? AND ?', start_date, end_date)
      .group(:id, :link, :name, :image_url)
      .select(:id, :link, :name, :image_url, "ARRAY[#{dates}] AS average_prices")
      .order(:name)
  }
end
