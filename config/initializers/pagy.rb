# config/initializer/pagy.rb
require 'pagy/extras/bulma'
require 'pagy/extras/array'

Pagy::DEFAULT[:items] = 50
Pagy::DEFAULT.freeze
