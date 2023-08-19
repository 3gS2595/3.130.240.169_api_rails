require './config/environment/'

CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = 'crystal-hair'
  config.aws_acl    = 'private'
  config.root = Rails.root
  config.aws_credentials = {
    access_key_id: Rails.application.credentials.aws[:access_key_id],
    secret_access_key: Rails.application.credentials.aws[:secret_access_key],
    region: 'us-east-1',
    endpoint: 'https://nyc3.digitaloceanspaces.com',
  }
end
