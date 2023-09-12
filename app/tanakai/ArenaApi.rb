require './config/environment/'

Arena.configure do |config|
    config.access_token = 'XC3fJj8wxLJIi0Bt39sxsoMpJ_39WpQtrLC7tD9ACwg'
end

Kernal.where(file_type: ".pdf").delete_all
Kernal.where(file_type: "link").delete_all
Kernal.where(file_type: ".avif").delete_all
Mixtape.delete_all
#e = Arena.block('964879')

i = 0
e = Arena.user_channels('494214', options={page: i}).channels
while e.length > 0
  e.each do |a| 
    title = a.title
    puts(a.title)
    chId = a.id
    if !Mixtape.exists?(name: title)
      @mix = Mixtape.create(
        name: title,
        created_at: a.created_at,
        updated_at: a.updated_at
      )
    end
    @mixtape = Mixtape.find_by(name: title)

    n = 0
    b = Arena.channel(chId, options={page: n}).contents
    while b.length > 0
      b.each do |a| 
        puts(a.class)
        author = a.user.username
        if a.class.to_s.include? "Link"
          created_at = a.created_at
          updated_at = a.updated_at
          description = a.description
          file_name = a.title
          url_path =  a.image.original.url

          if !Kernal.exists?(url: a.source.url)
            tempfile = Down.download(url_path)
            save_path = "/home/ubuntu"
            file_type = File.extname(tempfile.path)
            uuid = SecureRandom.uuid
            file_size = File.size(tempfile.path)
            file_path = uuid + ".avif"
            image = MiniMagick::Image.open(tempfile.path)
            image.format(".avif")
            image.write "#{save_path}/#{file_path}"
            image.resize "100x100"
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

            File.delete(tempfile.path)
            File.delete("#{save_path}/#{file_path}")
            File.delete("#{save_path}/nail/#{file_path}")

            @link = Kernal.create(
              file_path:file_path,
              file_name:file_name,
              file_type:"link",
              size:file_size,
              description:description,
              url:a.source.url,
              time_posted: created_at,
              created_at: created_at,
              updated_at: updated_at,
              author: author
            )
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
            puts(created_at)
            puts(updated_at)
            puts(description)
            puts(url_path)
            puts(file_size)
          elsif !@mixtape.content.include? Kernal.where(url: a.source.url)[0].id
            @mixtape.update(content: @mixtape.content.push(Kernal.where(url: a.source.url)[0].id))
          end
        end

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
            image.format(".avif")
            image.resize "100x100"
            image.write "#{save_path}/nail/#{uuid}.avif"

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
              body: File.read("#{save_path}/nail/#{uuid}.avif"),
              acl: "private"
            })

            File.delete(temppdf.path)
            File.delete("#{save_path}/nail/#{uuid}.avif")

            @link = Kernal.create(
              file_path:uuid,
              file_name:uuid,
              file_type:file_type,
              size:file_size,
              description:description,
              url:pdf_url,
              time_posted: created_at,
              created_at: created_at,
              updated_at: updated_at,
              author: author
            )

            @mixtape.update(content: @mixtape.content.push(@link.id)) 
            puts()
            puts(nail_path)
            puts(description)
            puts(file_name)
          elsif !@mixtape.content.include? Kernal.where(url: pdf_url)[0].id
            @mixtape.update(content: @mixtape.content.push(Kernal.where(url: pdf_url)[0].id))
          end
        end

        
        if a.class.to_s.include? "Image"
          created_at = a.created_at
          updated_at = a.updated_at
          description = a.description
          file_name = a.title

          if(a.image.nil?)
            url_path = a.source.url
          else
            url_path =  a.image.original.url
          end
          if Kernal.exists?(url: url_path)
            Kernal.where(url: url_path).delete_all
          end
          if !Kernal.exists?(url: url_path)
            tempfile = Down.download(url_path)
            save_path = "/home/ubuntu"
            file_type = File.extname(tempfile.path)
            uuid = SecureRandom.uuid
            file_path = uuid + ".avif" 
            file_size = File.size(tempfile.path)
            FileUtils.mv(tempfile.path, "#{save_path}/#{uuid}#{file_type}")
            image = MiniMagick::Image.open("#{save_path}/#{uuid}#{file_type}")
            image.format(".avif")
            image.write "#{save_path}/#{uuid}.avif"
            image.resize "100x100"
            image.write "#{save_path}/nail/#{uuid}.avif"

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
              body: File.read("#{save_path}/#{uuid}.avif"),
              acl: "private"
            })
            s3client.put_object({
              bucket: "crystal-hair-nail",
              key: 'nail_' + file_path,
              body: File.read("#{save_path}/nail/#{uuid}.avif"),
              acl: "private"
            })

            File.delete("#{save_path}/#{uuid}#{file_type}")
            File.delete("#{save_path}/#{uuid}.avif")
            File.delete("#{save_path}/nail/#{uuid}.avif")

            @link = Kernal.create(
              file_path:file_path,
              file_name:file_name,
              file_type:".avif",
              size:file_size,
              description:description + " are.na",
              url:url_path,
              time_posted: created_at,
              created_at: created_at,
              updated_at: updated_at,
              author: author
            )
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
            puts(created_at)
            puts(updated_at)
            puts(description)
            puts(url_path)
            puts(file_size)
          elsif !@mixtape.content.include? Kernal.where(url: url_path)[0].id
            @mixtape.update(content: @mixtape.content.push(Kernal.where(url: url_path)[0].id))
          end
        end

        if a.class.to_s.include? "Text"

          if !Kernal.exists?(description: a.content)
            @link = Kernal.create(
              file_type:".txt",
              description: a.content,
              time_posted: a.created_at,
              created_at: a.created_at,
              updated_at: a.updated_at,
              author: author
            )
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
          elsif !@mixtape.content.include? Kernal.where(description: a.content)[0].id
            @mixtape.update(content: @mixtape.content.push(Kernal.where(description: a.content)[0].id))
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
