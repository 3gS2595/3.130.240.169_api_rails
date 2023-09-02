require './config/environment/'

Arena.configure do |config|
    config.access_token = 'XC3fJj8wxLJIi0Bt39sxsoMpJ_39WpQtrLC7tD9ACwg'
end

Kernal.where(file_type: ".pdf").delete_all

i = 0
e = Arena.user_channels('494214', options={page: i}).channels
while e.length > 0
  e.each do |a| 
    title = a.title
    chId = a.id
    puts(title)
    if !Mixtape.exists?(name: title)
      @mix = Mixtape.create(
        name: title
      )
    end
    @mixtape = Mixtape.find_by(name: title)

    n = 0
    b = Arena.channel(chId, options={page: n}).contents
    while b.length > 0
      b.each do |a| 
        puts(a.class)
        if a.class.to_s.include? "Attachment"
          pdf_url = a.attachment.url
          url_path =  a.image.original.url
          created_at = a.created_at
          updated_at = a.updated_at
          if !Kernal.exists?(url: pdf_url)

            temppdf = Down.download(pdf_url)
            
            file_type = File.extname(temppdf.path)
            uuid = SecureRandom.uuid
            pdf_path = uuid +  File.extname(temppdf.path)
            file_name = a.title
            file_size = File.size(temppdf.path)
            description = a.description

            tempfile = Down.download(url_path)
            nail_path = uuid + File.extname(tempfile.path)
            save_path = "/home/ubuntu"
            FileUtils.mv(tempfile.path, "#{save_path}/#{nail_path}")
            image = MiniMagick::Image.open("#{save_path}/#{nail_path}")
            image.resize "165x165"
            image.write "#{save_path}/nail/#{nail_path}"

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
              key: pdf_path,
              body: File.read(temppdf.path),
              acl: "private"
            })
            s3client.put_object({
              bucket: "crystal-hair-nail",
              key: 'nail_' + nail_path,
              body: File.read("#{save_path}/nail/#{nail_path}"),
              acl: "private"
            })

            File.delete(temppdf.path)
            File.delete("#{save_path}/nail/#{nail_path}")

            @link = Kernal.create(
              file_path:uuid,
              file_name:uuid,
              file_type:file_type,
              size:file_size,
              description:description,
              url:pdf_url,
              time_posted: created_at,
              created_at: created_at,
              updated_at: updated_at
            )

            @mixtape.update(content: @mixtape.content.push(@link.id)) 
            puts()
            puts(nail_path)
            puts(description)
            puts(file_name)
          end


        end
        if a.class.to_s.include? "Image"
          created_at = a.created_at
          updated_at = a.updated_at
          description = a.description
          file_name = a.title
          url_path =  a.image.original.url

          if !Kernal.exists?(url: url_path)
            tempfile = Down.download(url_path)
            save_path = "/home/ubuntu"
            file_type = File.extname(tempfile.path)
            file_path = SecureRandom.uuid + file_type
            file_size = File.size(tempfile.path)
            FileUtils.mv(tempfile.path, "#{save_path}/#{file_path}")
            image = MiniMagick::Image.open("#{save_path}/#{file_path}")
            image.resize "165x165"
            image.write "#{save_path}/nail/#{file_path}"
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
              key: file_path,
              body: File.read("#{save_path}/#{file_path}"),
              acl: "private"
            })
            s3client.put_object({
              bucket: "crystal-hair-nail",
              key: 'nail_' + file_path,
              body: File.read("#{save_path}/nail/#{file_path}"),
              acl: "private"
            })

            File.delete("#{save_path}/#{file_path}")
            File.delete("#{save_path}/nail/#{file_path}")

            @link = Kernal.create(
              file_path:file_path,
              file_name:file_name,
              file_type:file_type,
              size:file_size,
              description:description,
              url:url_path,
              time_posted: created_at,
              created_at: created_at,
              updated_at: updated_at
            )
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
            puts(created_at)
            puts(updated_at)
            puts(description)
            puts(url_path)
            puts(file_size)
          end
        end

      end
      n = n + 1
      b = Arena.channel(chId, options={page: n}).contents
    end
  end
  i = i + 1
  e = Arena.user_channels('494214', options={page: i}).channels
end
