class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def create
    @urls = params[:urls]
    urls = extract_urls_from_params(@urls)
    invalid_urls = {}

    urls.each do |url|
      category_link = CategoryLink.find_or_initialize_by(url:)
      invalid_urls[url] = category_link.errors.full_messages unless category_link.save
      category_link.touch if category_link.persisted?
    end

    if invalid_urls.any?
      flash[:error] = invalid_urls.map do |url, messages|
        "URL: #{url} - Errors: #{messages.join(', ')}"
      end
      render :index, status: :unprocessable_content
    else
      products_data = fetch_products_data_from_urls(urls)
      @products = Product.insert_all(products_data)
      redirect_to root_path
    end
  end

  private

  def fetch_products_data_from_urls(urls)
    urls.flat_map { |start_url| ProductScraper.call(start_url) }.uniq
  end

  def extract_urls_from_params(urls_param)
    urls_param.present? ? urls_param.split("\n").map(&:strip).uniq : []
  end
end
