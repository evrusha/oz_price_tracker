source "https://rubygems.org"

ruby "3.2.5"

gem "rails", "~> 7.1.4"

gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem 'dotenv-rails', '~> 3.1', '>= 3.1.4'
  gem 'rspec-rails', '~> 7.0', '>= 7.0.1'
end

group :development do
  gem "web-console"
end

group :test do
  gem 'simplecov', '~> 0.22.0', require: false
end
