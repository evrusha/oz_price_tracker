class ProductsController < ApplicationController
  def index; end

  def create
    start_url = params[:urls].split("\n").first
    products_data = ProductScraper.call(start_url)
    @products = Product.create(products_data)
  end
end
