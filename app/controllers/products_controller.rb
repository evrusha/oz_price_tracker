class ProductsController < ApplicationController
  include Pagy::Backend

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
      @category_links.each do |link|
        ScrapJob.perform_async(link.url)
      end
      flash[:info] = t('.info')
      redirect_to root_path
    end
  end

  def statistics
    respond_to do |format|
      format.html
      format.turbo_stream do
        @info = params[:info]
        @start_date = params[:start_date]&.to_date
        @end_date = params[:end_date]&.to_date
        @date_range = @start_date..@end_date
        @pagy, @result = pagy(statistics_products(@info).average_price_by_date(@start_date, @end_date), limit: 10)
      end
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

  def format_error_messages(invalid_urls)
    invalid_urls.map do |url, messages|
      "URL: #{url} - Errors: #{messages.join(', ')}"
    end
  end

  def statistics_products(info)
    if CategoryLink.find_or_initialize_by(url: info).valid?
      Product.where(link: info)
    else
      Product.where('name LIKE ?', "%#{Product.sanitize_sql_like(info)}%")
    end
  end
end
