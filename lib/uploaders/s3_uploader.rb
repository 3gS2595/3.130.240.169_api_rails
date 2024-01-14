require './config/environment/'

class S3Uploader
  def initialize(source, s, m, l, source_key)
    puts('uploading new key ' + source_key)
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
      bucket: "crystal-hair-s",
      key: "s_160_" + source_key,
      body: s,
      acl: "private"
    })
    s3client.put_object({
      bucket: "crystal-hair-m",
      key: "m_400_" + source_key,
      body: m,
      acl: "private"
    })
    s3client.put_object({
      bucket: "crystal-hair-l",
      key: "l_1000_" + source_key,
      body: l,
      acl: "private"
    })
  end
end


