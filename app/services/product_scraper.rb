class ProductScraper
  attr_reader :start_url, :products_data

  def initialize(start_url)
    @start_url = start_url
    @products_data = []
  end

  def self.call(start_url)
    new(start_url).fetch_all_products
  end

  def fetch_all_products
    url = start_url

    while url
      Rails.logger.debug { "Scraping: #{url}" }
      url = scrape_products(url)
    end

    products_data
  end

  private

  def scrape_products(url)
    response = fetch_page(url)
    return unless response

    doc = parse_html(response)
    process_articles(doc)
    find_next_page(doc, url)
  end

  def fetch_page(url)
    response = HTTParty.get(url)
    return response if response.success?

    Rails.logger.error("Failed to fetch page: #{url}")
    nil
  end

  def parse_html(response)
    Nokogiri::HTML(response.body)
  end

  def process_articles(doc)
    doc.css('article').each do |article|
      process_article(article)
    end
  end

  def process_article(article)
    product_info = extract_product_info(article)
    products_data << product_info if product_info
  end

  def extract_product_info(article)
    {
      oz_id: extract_oz_id(article),
      name: extract_name(article),
      link: extract_link(article),
      price: extract_price(article),
      image_url: extract_image_url(article)
    }
  rescue StandardError => e
    Rails.logger.error("Error processing article: #{e.message}")
  end

  def extract_oz_id(article)
    article['data-value']
  end

  def extract_image_url(article)
    article.at_css('img')['src']
  end

  def extract_link(article)
    article.at_css('a')['href']
  end

  def extract_name(article)
    article.at_css('a span').text.strip
  end

  def extract_price(article)
    article.at_css('b').text.tr(',', '.').to_f
  end

  def find_next_page(doc, current_url)
    next_page = doc.at_css('a.pg-next:not(.disabled)')
    return unless next_page

    URI.join(current_url, next_page['href']).to_s
  end
end
