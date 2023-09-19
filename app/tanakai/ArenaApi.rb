require './config/environment/'

Mixtape.delete_all
def genImageAndThumb(temp_path, save_path, save_name)
  image = MiniMagick::Image.open(temp_path)
  image.format(".avif")
  image.write "#{save_path}/#{save_name}"
  image.resize "100x100"
  image.write "#{save_path}/nail_#{save_name}"
end
def genThumb(temp_path, save_path, save_name)
  image = MiniMagick::Image.open(temp_path)
  image.format(".avif")
  image.resize "100x100"
  image.write "#{save_path}/nail_#{save_name}"
end
def cleanup(tempfile)
  File.delete(tempfile)
  Dir.glob("/home/ubuntu/*.avif").map do |f| File.delete(f) end
end

Arena.configure do |config|
    config.access_token = 'XC3fJj8wxLJIi0Bt39sxsoMpJ_39WpQtrLC7tD9ACwg'
end

fetchChannelPageNum = 1
channels = Arena.user_channels('494214', options={page: fetchChannelPageNum}).channels
while channels.length > 0
  channels.each do | chAttr | 
    channelName = chAttr.title
    channelId = chAttr.id
    if !Mixtape.exists?(name: channelName)
      @mix = Mixtape.create(
        name: channelName,
        created_at: chAttr.created_at,
        updated_at: chAttr.updated_at
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
              File.read("#{save_path}/nail_#{uuid_avif}"), 
              uuid_avif,
              'nail_' + uuid_avif
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
              author: a.user.username
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

            S3Uploader.new(
              File.read(temppdf.path), 
              File.read("#{save_path}/nail_#{uuid_avif}"), 
              uuid +  File.extname(temppdf.path), 
              'nail_' + uuid_avif
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
              author: a.user.username
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
              File.read("#{save_path}/nail_#{uuid_avif}"), 
              uuid_avif, 
              'nail_' + uuid_avif
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
              author: a.user.username
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
              author: a.user.username
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
