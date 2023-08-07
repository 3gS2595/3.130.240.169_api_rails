require 'rubygems'
require 'nokogiri'
require 'net/http'
require "down"
require "fileutils"
require 'open-uri'
require './config/environment/'
require 'aws-sdk-s3'
require 'mini_magick'

class ScrapperModule
  
  def scrape
    doc = Nokogiri::HTML(Net::HTTP.get(URI("https://www.finalhotdesert.com/past")))
    
    outLinks = doc.css('div.text-block a').map { |link| link['href'] }
    outLinks.each do |e|
      url = e.sub! 'http://', 'https://'
      link = Nokogiri::HTML(Net::HTTP.get(URI(e)))

      # create new link_content
      if !SourceUrl.exists?(domain: "https://www.finalhotdesert.com/")
         SourceUrl.create(
            domain: "https://www.finalhotdesert.com/",
            logo_path: "finalHostDesert.png"
         )
      end

      if !Hypertext.exists?(url: "https://www.finalhotdesert.com/past")
        Hypertext.create(
          source_url_id:SourceUrl.find_by(domain: "https://www.finalhotdesert.com/").id,
          url: "https://www.finalhotdesert.com/past",
          logo_path: "finalHotDesert.png",
          name: "Final Hot Desert Past",
        )
      end
      @link = LinkContent.create(
        source_url_id: SourceUrl.find_by(domain: "https://www.finalhotdesert.com/past").id,
        url: e
      )

      link.css('div.container').css('div.page-element').each do|n|
        imgName = n.attr('data-prefix')
        imgType = n.attr('data-suffix')
        if imgName && !Kernal.exists?(file_name: imgName)
          file_path = imgName.split('/').last + "." + imgType
          tempfile = Down.download(imgName + "." + imgType)
          FileUtils.mv(tempfile.path, "/home/ubuntu/img/#{tempfile.original_filename}")
          Aws.use_bundled_cert!
          client = Aws::S3::Client.new(
            access_key_id: Rails.application.credentials.aws[:access_key_id],
            secret_access_key: Rails.application.credentials.aws[:secret_access_key],
            endpoint: 'https://nyc3.digitaloceanspaces.com',
            force_path_style: false,
            region: 'us-east-1'
          )
          client.put_object({
            bucket: "crystal-hair",
            key: file_path,
            body: File.read("/home/ubuntu/img/#{tempfile.original_filename}"),
            acl: "public-read"
          })

          image = MiniMagick::Image.open("/home/ubuntu/img/#{tempfile.original_filename}")
          image.path #=> "/home/ubuntu/img/#{tempfile.original_filename}"
          image.resize "180x180"
          image.write "/home/ubuntu/nail/#{tempfile.original_filename}"
          client.put_object({
            bucket: "crystal-hair-nail",
            key: file_path,
            body: File.read("/home/ubuntu/nail/#{tempfile.original_filename}"),
            acl: "public-read"
          })


          #create new kernal 
          Kernal.create(
            hypertext_id:@link.id, 
            file_path: file_path, 
            file_name:imgName, 
            file_type:imgType,
            url: e
          )
        end
      end
    end
  end
end

