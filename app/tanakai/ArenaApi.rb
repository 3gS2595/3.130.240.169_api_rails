require './config/environment/'
def genImageAndThumb(temp_path, save_path, save_name)
  image = MiniMagick::Image.open(temp_path)
  image.format(".avif")
  image.write "#{save_path}/#{save_name}"
  image.resize "1000x1000"
  image.write "#{save_path}/l_1000_#{save_name}"
  image.resize "400x400"
  image.write "#{save_path}/m_400_#{save_name}"
  image.resize "160x160"
  image.write "#{save_path}/s_160_#{save_name}"
end

def genThumb(temp_path, save_path, save_name)
  image = MiniMagick::Image.open(temp_path)
  image.format(".avif")
  image.resize "160x160"
  image.write "#{save_path}/s_160_#{save_name}"
  image.resize "400x400"
  image.write "#{save_path}/m_400_#{save_name}"
  image.resize "1000x1000"
  image.write "#{save_path}/l_1000_#{save_name}"
end

def pdfUp(source, s, m, l, source_key, nail_key)
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
    key: "s_160_" + nail_key,
    body: s,
    acl: "private"
  })
  s3client.put_object({
    bucket: "crystal-hair-m",
    key: "m_400_" + nail_key,
    body: m,
    acl: "private"
  })
  s3client.put_object({
    bucket: "crystal-hair-l",
    key: "l_1000_" + nail_key,
    body: l,
    acl: "private"
  })
end


def cleanup(tempfile)
  File.delete(tempfile)
  Dir.glob("/home/ubuntu/*.avif").map do |f| File.delete(f) end
end


fetchChannelPageNum = 1
# SETUP AND ARENA AUTHORIZATION 
Arena.configure do |config|
    config.access_token = 'XC3fJj8wxLJIi0Bt39sxsoMpJ_39WpQtrLC7tD9ACwg'
end
channels = Arena.user_channels('494214', options={page: fetchChannelPageNum}).channels

# ITERATES ACROSS ALL USERS CHANNELS
while channels.length > 0
  channels.each do | chAttr | 
    channelName = chAttr.title
    channelId = chAttr.id

    if !Mixtape.exists?(name: channelName)
      @mix = Mixtape.create(
        name: channelName,
        created_at: chAttr.created_at,
        updated_at: chAttr.updated_at,
        permissions: ["c611ad6c-4826-48bb-98fe-cada1158e3ce"]
      )
    end

    @mixtape = Mixtape.find_by(name: channelName)
    fetchBlockPageNum = 1
    page = Arena.channel(channelId, options={page: fetchBlockPageNum}).contents
    while page.length > 0
      page.each do |a| 

        puts(channelName + " " + a.class.to_s[5..-1])
        uuid = SecureRandom.uuid
        uuid_avif = uuid + ".avif"
        save_path = "/home/ubuntu"

        # LINK BLOCK TYPE
        if a.class.to_s.include? "Link"
          if !Kernal.exists?(url: a.source.url)
            tempfile = Down.download(a.image.original.url)
            genImageAndThumb(tempfile.path, save_path, uuid_avif)

            S3Uploader.new(
              File.read("#{save_path}/#{uuid_avif}"), 
              File.read("#{save_path}/s_160_#{uuid_avif}"), 
              File.read("#{save_path}/m_400_#{uuid_avif}"), 
              File.read("#{save_path}/l_1000_#{uuid_avif}"), 
              uuid_avif, 
            )
            @link = Kernal.create(
              id: uuid,
              file_path:uuid_avif,
              file_name: a.title,
              file_type:"link",
              size: File.size(tempfile.path),
              description: a.description,
              url:a.source.url,
              time_posted: a.created_at,
              created_at: a.created_at,
              updated_at: a.updated_at,
              key_words: "are.na",
              author: a.user.username,
              permissions: ["c611ad6c-4826-48bb-98fe-cada1158e3ce"]
            )
            cleanup(tempfile.path)
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
          elsif !@mixtape.content.include? Kernal.find_by(url: a.source.url).id
            @mixtape.update(content: @mixtape.content.push(Kernal.find_by(url: a.source.url).id))
          end 
        end

        # ATTATCHMENT BLOCK TYPE
        if a.class.to_s.include? "Attachment"
          if !Kernal.exists?(url: a.attachment.url)
            temppdf = Down.download(a.attachment.url)
            tempfile = Down.download(a.image.original.url)
            genThumb(tempfile.path, save_path, uuid_avif) 

            pdfUp(
              File.read(temppdf.path), 
              File.read("#{save_path}/s_160_#{uuid_avif}"), 
              File.read("#{save_path}/m_400_#{uuid_avif}"), 
              File.read("#{save_path}/l_1000_#{uuid_avif}"), 
              uuid +  File.extname(temppdf.path), 
              uuid_avif
            )
            @link = Kernal.create(
              id: uuid,
              file_path:uuid,
              file_name: a.title,
              file_type: File.extname(temppdf.path),
              size: File.size(temppdf.path),
              description: a.description,
              url:a.attachment.url,
              time_posted: a.created_at,
              created_at: a.created_at,
              updated_at: a.updated_at,
              key_words: "are.na",
              author: a.user.username,
              permissions: ["c611ad6c-4826-48bb-98fe-cada1158e3ce"]
            )
            File.delete(temppdf.path)
            cleanup(tempfile.path)
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
          elsif !@mixtape.content.include? Kernal.find_by(url: a.attachment.url).id
            @mixtape.update(content: @mixtape.content.push(Kernal.find_by(url: a.attachment.url).id))
          end
        end
        
        # IMAGE BLOCK TYPE
        if a.class.to_s.include? "Image"
          url_path =  a.image.nil?  ? a.source.url : a.image.original.url
          if !Kernal.exists?(url: url_path)
            tempfile = Down.download(url_path)
            genImageAndThumb(tempfile.path, save_path, uuid_avif) 

            S3Uploader.new(
              File.read("#{save_path}/#{uuid_avif}"), 
              File.read("#{save_path}/s_160_#{uuid_avif}"), 
              File.read("#{save_path}/m_400_#{uuid_avif}"), 
              File.read("#{save_path}/l_1000_#{uuid_avif}"), 
              uuid_avif, 
            )
            @link = Kernal.create(
              id: uuid,
              file_path: uuid_avif,
              file_name: a.title,
              file_type:".avif",
              size: File.size(tempfile.path),
              description:a.description,
              url:url_path,
              time_posted: a.created_at,
              created_at: a.created_at,
              updated_at: a.updated_at,
              key_words: "are.na",
              author: a.user.username,
              permissions: ["c611ad6c-4826-48bb-98fe-cada1158e3ce"]
            )
            cleanup(tempfile.path)
            @mixtape.update(content: @mixtape.content.push(@link.id)) 
          elsif !@mixtape.content.include? Kernal.find_by(url: url_path).id
            @mixtape.update(content: @mixtape.content.push(Kernal.find_by(url: url_path).id))
          end
        end

        # TEXT BLOCK TYPE
        if a.class.to_s.include? "Text"
          if !Kernal.exists?(description: a.content)
            @link = Kernal.create(
              id: uuid,
              file_type:".txt",
              description: a.content,
              time_posted: a.created_at,
              created_at: a.created_at,
              updated_at: a.updated_at,
              key_words: "are.na",
              author: a.user.username,
              permissions: ["c611ad6c-4826-48bb-98fe-cada1158e3ce"]
            )
            @mixtape.update(content: @mixtape.content.push(@link.id))
          elsif !@mixtape.content.include? Kernal.find_by(description: a.content).id
            @mixtape.update(content: @mixtape.content.push(Kernal.find_by(description: a.content).id))
          end
        end
      end
      fetchBlockPageNum = fetchBlockPageNum + 1
      page = Arena.channel(channelId, options={page: fetchBlockPageNum}).contents
    end
  end
  fetchChannelPageNum = fetchChannelPageNum + 1
  channels = Arena.user_channels('494214', options={page: fetchChannelPageNum}).channels
end
