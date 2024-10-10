class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def create
    urls = extract_urls_from_params
    invalid_urls = validate_category_links(urls)

    if invalid_urls.any?
      flash[:error] = format_error_messages(invalid_urls)
      render :index, status: :unprocessable_content
    else
      save_category_links_and_products
      flash[:success] = t('.success')
      redirect_to root_path
    end
  end

  private

  def extract_urls_from_params
    @urls = params[:urls]
    @urls.to_s.split("\n").map(&:strip).uniq
  end

  def validate_category_links(urls)
    urls.each_with_object({}) do |url, invalid_urls|
      category_link = CategoryLink.find_or_initialize_by(url:)
      if category_link.valid?
        @category_links ||= []
        @category_links << category_link
      else
        invalid_urls[url] = category_link.errors.full_messages
      end
    end
  end

  def save_category_links_and_products
    CategoryLink.transaction do
      @category_links.each(&:save)
    end
    products_data = fetch_products_data_from_category_links
    save_products_with_price_history(products_data)
  end

  def fetch_products_data_from_category_links
    @category_links.flat_map { |start_url| ProductScraper.call(start_url.url) }.uniq
  end

  def save_products_with_price_history(products_data)
    products_data.each do |product_data|
      product = Product.create_with(product_data).find_or_initialize_by(oz_id: product_data[:oz_id])
      if product.persisted? && product.price != product_data[:price]
        PriceHistory.create!(product:, price_old: product.price, price_new: product_data[:price])
        product.price = product_data[:price]
      end
      product.save!
    end
  end

  def format_error_messages(invalid_urls)
    invalid_urls.map do |url, messages|
      "URL: #{url} - Errors: #{messages.join(', ')}"
    end
  end
end
