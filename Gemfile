source 'https://rubygems.org'

# Specify Ruby version
ruby '2.3.8'

# Rails version requirement
gem 'rails', '~> 4.2.11'

# Example: pin Loofah to 2.18 or earlier
gem 'loofah', '~> 2.13.0'

gem 'rails-html-sanitizer', '~> 1.4.2'

# Database gems (use pg in production, sqlite3 in development/test, etc.)
group :development, :test do
  gem 'sqlite3', '~> 1.3.13'
end

group :production do
  gem 'pg', '~> 0.21'
end

# Asset pipeline dependencies
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'

# Use jbuilder for JSON APIs
gem 'jbuilder', '~> 2.0'

# Optional debugging, etc.
group :development do
  gem 'byebug', platform: :mri
end

# Add any other gems your app requires below this line
# ...
