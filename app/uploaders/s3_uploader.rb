require './config/environment/'

class S3Uploader
  def initialize(source, nail, source_key, nail_key)
    print('uploading new key ' + source_key)
    Aws.use_bundled_cert!
    s3client = Aws::S3::Client.new(
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      endpoint: 'https://nyc3.digitaloceanspaces.com',
      force_path_style: false,
      region: 'us-east-1'
    )
    s3client.put_object({
      bucket: "crystal-hair",
      key: source_key,
      body: source,
      acl: "private"
    })
    s3client.put_object({
      bucket: "crystal-hair-nail",
      key: nail_key,
      body: nail,
      acl: "private"
    })
  end
end


