class ProductsController < ApplicationController
  def index; end

  def create
    urls = extract_urls_from_params
    invalid_urls = validate_category_links(urls)

    if invalid_urls.present?
      flash[:error] = format_error_messages(invalid_urls)
      render :index, status: :unprocessable_content
    else
      CategoryLink.transaction do
        @category_links.each(&:save)
      end
      products_data = fetch_products_data_from_category_links
      if products_data.present?
        save_products_with_price_history(products_data)
        flash[:success] = t('.success')
      else
        flash[:warning] = t('.warning')
      end
      redirect_to root_path
    end
  end

  def statistics
    info = params[:info]
    if params[:info].present?
      start_date = params[:start_date].to_date
      end_date = params[:end_date].to_date
      @date_range = start_date..end_date
      @result = statistics_products(info).average_price_by_date(start_date, end_date)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
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

  def fetch_products_data_from_category_links
    @category_links.flat_map { |start_url| ProductScraper.call(start_url.url) }.uniq
  end

  def save_products_with_price_history(products_data)
    products_data.each do |product_data|
      product = begin
        Product.create_with(product_data).find_or_initialize_by(oz_id: product_data[:oz_id])
      rescue StandardError => e
        Rails.logger.error e.message
      end
      if product.new_record?
        PriceHistory.create!(product:, price_old: nil, price_new: product_data[:price])
      elsif product.price != product_data[:price]
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

  def statistics_products(info)
    if CategoryLink.find_or_initialize_by(url: info).valid?
      Product.where(link: info)
    else
      Product.where('name LIKE ?', "#{Product.sanitize_sql_like(info)}%")
    end
  end
end
