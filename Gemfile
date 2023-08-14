source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.5"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]


gem "rack-cors"
gem "nokogiri"
gem 'aws-sdk-s3'
gem 'devise'
gem 'open-uri'
gem 'kimurai'
gem 'tanakai'
gem 'down'
gem 'fileutils'
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'mini_magick'
gem 'ransack', :github => 'activerecord-hackery/ransack', :branch => 'main'
gem 'wt_s3_signer', '~> 1.0', '>= 1.0.2'
gem 'kaminari'
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end


gem "devise-jwt", "~> 0.11.0"
