# config/initializer/pagy.rb
require 'pagy/extras/bulma'
require 'pagy/extras/array'

Pagy::DEFAULT[:items] = 40
Pagy::DEFAULT.freeze
