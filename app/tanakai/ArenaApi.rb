
require './config/environment/'
Arena.configure do |config|
    config.access_token = 'XC3fJj8wxLJIi0Bt39sxsoMpJ_39WpQtrLC7tD9ACwg'
end
contents = Arena.user_channels('494214', options={page: 0}).channels[0].contents

e = Arena.channel('1687235', options={}).content
puts e

puts(Arena.user_channels('494214', options={}).channels[0].id)
puts(Arena.user_channels('494214', options={}).channels[0].title)
