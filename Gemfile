source "https://rubygems.org"

ruby ">= 3.4.7"

gem "rails", "~> 8.1.3"
gem "bcrypt", "~> 3.1.7"

# Asset pipeline
gem "propshaft"

# Use JavaScript with ESM import maps
gem "importmap-rails"

# Hotwire
gem "turbo-rails"
gem "stimulus-rails"

# CSS
# gem "tailwindcss-rails", "~> 4.4.0"

# Server
gem "puma", ">= 5.0"

# Auth & Permissions
gem "devise"
gem "omniauth-google-oauth2"
gem "omniauth-facebook"
gem "omniauth-apple"
gem "rack-attack"  # Rate limiting for auth endpoints

# UI
gem "pagy"

# Data & Logic
gem "csv"
gem "ransack"
gem "groupdate"
gem "dotenv-rails", groups: [:development, :test]

# Infrastructure
gem "sentry-ruby"
gem "sentry-rails"
gem "stripe"
gem "httparty"
gem "resend"

# Background jobs & caching
gem "solid_cache"
gem "solid_queue"

# Database
gem "pg", "~> 1.5"

gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "better_errors"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "database_consistency"
  gem "debug", platforms: %i[mri], require: "debug/prelude"
  gem "dotenv"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "letter_opener", "~> 1.10"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-capybara", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "rubycritic"
  gem "standard", ">= 1.35.1"
end

group :development do
  gem "rack-mini-profiler"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "tailwindcss-rails", "~> 3.3.1"
