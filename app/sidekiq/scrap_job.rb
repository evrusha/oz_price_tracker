class ScrapJob
  include Sidekiq::Job

  def perform(url)
    products_data = fetch_products_data_from_category_links(url)
    return if products_data.blank?

    save_products_with_price_history(products_data)
  end

  private

  def fetch_products_data_from_category_links(url)
    ProductScraper.call(url)
  end

  def save_products_with_price_history(products_data)
    products_data.each do |product_data|
      product = Product.create_with(product_data).find_or_initialize_by(oz_id: product_data[:oz_id])
      if product.new_record?
        PriceHistory.create!(product:, price_old: nil, price_new: product_data[:price])
      elsif product.price != product_data[:price]
        PriceHistory.create!(product:, price_old: product.price, price_new: product_data[:price])
        product.price = product_data[:price]
      end
      product.save!
    end
  rescue StandardError => e
    Rails.logger.error e.message
  end
end
