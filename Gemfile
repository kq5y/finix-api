source "https://rubygems.org"

gem "rails", "~> 8.0.2"

gem "puma", ">= 5.0"

gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[windows jruby]

gem "bootsnap", require: false

gem "kamal", require: false

gem "thruster", require: false

gem "rack-cors"

group :development do
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  gem "sqlite3", ">= 2.1"

  gem "brakeman", require: false
end

group :production do
  gem "pg"
end

gem "dotenv-rails"

# Authentication
gem "faraday"
gem "jwt"

# Soft delete
gem "discard", "~> 1.4"

# Pagination
gem "kaminari"

# Search and sort
gem "ransack"
