# config/initializer/pagy.rb
require 'pagy/extras/bulma'
require 'pagy/extras/array'

Pagy::DEFAULT[:items] = 35
Pagy::DEFAULT.freeze
