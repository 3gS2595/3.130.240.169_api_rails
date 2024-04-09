source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.5"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

gem "rack-cors"
gem 'devise'
gem 'goldiloader'
gem 'colorize', '~> 1.1'
gem "devise-jwt", "~> 0.11.0"
gem "bootsnap", require: false

# File mod/access
gem 'down'
gem 'rmagick'
gem 'mini_magick'
gem 'fileutils'

# Sidekiq Scraping
gem 'sidekiq-scheduler'
gem 'sidekiq'
gem 'redis'
gem 'kimurai'
gem 'tanakai'
gem 'open-uri'
gem "nokogiri"

# ActiveRecord
gem 'kaminari'
gem 'fast_page'
gem 'ransack', :github => 'activerecord-hackery/ransack', :branch => 'main'

# AWS
gem 'carrierwave-aws'
gem 'carrierwave', '~> 1.0'
gem 'aws-sigv4'
gem 'wt_s3_signer', '~> 1.0', '>= 1.0.2'
gem 'aws-sdk-s3'

# External API gems
gem 'discordrb'
gem 'arena'
gem "tumblr_client"
gem 'instagram_basic_display'

# ONXX
gem 'numo-narray', '~> 0.9.2.1'
gem 'onnxruntime'

group :development do
    gem 'capistrano',         require: false
    gem 'capistrano-rvm',     require: false
    gem 'capistrano-rails',   require: false
    gem 'capistrano-bundler', require: false
    gem 'capistrano3-puma',   require: false
end
