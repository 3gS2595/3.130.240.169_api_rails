require './config/environment/'
require 'sidekiq-scheduler'
require 'json'
require 'uri'
require 'net/http'

url = URI("https://instagram-api-20231.p.rapidapi.com/api/user_posts/1372909208")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["X-RapidAPI-Key"] =  Rails.application.credentials.instagram[:key_0]
request["X-RapidAPI-Host"] =  Rails.application.credentials.instagram[:host_0]

response = http.request(request)
puts response.read_body

