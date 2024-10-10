class CategoryLink < ApplicationRecord
  validates :url, presence: true, uniqueness: true,
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validate :url_must_belong_to_oz_by
  validate :url_mustnt_scraped_within_last_three_hours, if: :persisted?

  private

  def url_must_belong_to_oz_by
    uri = begin
      URI.parse(url)
    rescue StandardError
      nil
    end
    return unless uri && uri.host != 'oz.by'

    errors.add(:url, 'must belong to oz.by host')
  end

  def url_mustnt_scraped_within_last_three_hours
    errors.add(:url, 'scraped within last 3 hours') if updated_at > 3.hours.ago
  end
end
