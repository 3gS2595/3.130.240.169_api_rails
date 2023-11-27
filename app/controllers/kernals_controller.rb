class KernalsController < ApplicationController
  before_action :authenticate_user!
  require "selenium-webdriver"
  
  # GET
  def index
    @permited = Kernal.where("permissions @> ARRAY[?]::varchar[]", [current_user.id])
    if !params.has_key?(:forceGraph)
      @q = params.has_key?(:mixtape) ? @permited.where(id: Mixtape.find(params[:mixtape]).content) : @permited
      @q = @q.ransack(search_params)
      @q.sorts = params.has_key?(:sort) ? params[:sort] : null
      @pagy, @page = params.has_key?(:page) ? pagy(@q.result) : @q.result 
   
      # presign urls
      signer = Aws::Sigv4::Signer.new(
        service: "s3",
        access_key_id: Rails.application.credentials.aws[:access_key_id],
        secret_access_key: Rails.application.credentials.aws[:secret_access_key],
        region: 'us-east-1'
      )
      @page.each do |kernal|
        if !kernal.file_path.nil? && kernal.file_path.length > 0
          key = kernal.file_path
          nailKey = kernal.file_path

          if kernal.file_type == ".pdf"
            key = kernal.id + ".pdf"
            nailKey = kernal.id + ".avif"
          end
          
          url = signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
          url_s = signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-s.nyc3.digitaloceanspaces.com/s_160_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
          url_m = signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-m.nyc3.digitaloceanspaces.com/m_400_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
          url_l = signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-l.nyc3.digitaloceanspaces.com/l_1000_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
          kernal.assign_attributes({ 
            :signed_url => url, 
            :signed_url_s => url_s, 
            :signed_url_m => url_m,
            :signed_url_l => url_l
          })
        end
      end
    else
      @q = params.has_key?(:mixtape) ? @permited.where(id: Mixtape.find(params[:mixtape]).content) : @permited
      @q = @q.ransack(search_params)
      @page = @q.result 
    end
    render json: @page
  end

  # GET
  def show
    @kernal = Kernal.find(params[:id])
    render json: @kernal
  end

  # POST /kernals
  def create
    uuid = SecureRandom.uuid
    @kernal = Kernal.new(
      file_path: uuid + params[:file_type],
      file_type: params[:file_type],
      time_posted: DateTime.now(),
      permissions: [current_user.id]
    )
    @kernal.id = uuid
    @kernal.save
    if (params.has_key?(:image))
      uploader = ImageUploader.new(@kernal)
      File.open(params[:image]) do |file| 
        uploader.store!(file) end
    end
    if (params.has_key?(:pdf))
      uploader = PdfUploader.new(@kernal)
      @kernal.update_attribute(:file_type, ".pdf")
      File.open(params[:pdf]) do |file| 
        uploader.store!(file) end
    end
    if (params.has_key?(:text))
      @kernal.update_attribute(:description, params[:text])
    end
    if params.has_key?(:mixtape) 
      @mixtape = Mixtape.find(params[:mixtape])
      @mixtape.update(content: @mixtape.content.push(@kernal.id))
      @mixtape.save
    end
    if params.has_key?(:url) 
      puts(params[:url])
      options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
      driver = Selenium::WebDriver.for(:firefox, options: options) 
      driver.navigate.to params[:url]
       
      @kernal.update_attribute(:url, params[:url])
      driver.save_screenshot("selenium.png")
      driver.quit
      file = File.open("./selenium.png")
      uploader = ImageUploader.new(@kernal)
      uploader.store!(file)
    end
    @kernal.save
    # presign urls
    signer = Aws::Sigv4::Signer.new(
      service: "s3",
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      region: 'us-east-1'
    )
    if !@kernal.file_path.nil? && @kernal.file_path.length > 0
      key = @kernal.file_path
      nailKey = @kernal.file_path
      if @kernal.file_type == ".pdf"
        key = @kernal.id + ".pdf"
        nailKey = @kernal.id + ".avif"
      end

      url = signer.presign_url(
        http_method: "GET",
        url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
        expires_in: 600,
        body_digest: "UNSIGNED-PAYLOAD"
      )
      url_s = signer.presign_url(
        http_method: "GET",
        url: "https://crystal-hair-s.nyc3.digitaloceanspaces.com/s_160_#{nailKey}",
        expires_in: 600,
        body_digest: "UNSIGNED-PAYLOAD"
      )
      url_m = signer.presign_url(
        http_method: "GET",
        url: "https://crystal-hair-m.nyc3.digitaloceanspaces.com/m_400_#{nailKey}",
        expires_in: 600,
        body_digest: "UNSIGNED-PAYLOAD"
      )
      url_l = signer.presign_url(
        http_method: "GET",
        url: "https://crystal-hair-l.nyc3.digitaloceanspaces.com/l_1000_#{nailKey}",
        expires_in: 600,
        body_digest: "UNSIGNED-PAYLOAD"
      )
      @kernal.assign_attributes({ 
        :signed_url => url, 
        :signed_url_s => url_s, 
        :signed_url_m => url_m,
        :signed_url_l => url_l
      })
    end

    render json: @kernal, status: :created, location: @kernal
  end

  # PATCH/PUT
  def update
    @kernal = Kernal.find(params[:id])
    if @kernal.update(kernal_params)
      render json: @kernal
    else
      render json: @kernal.errors, status: :unprocessable_entity
    end
  end

  # DELETE
  def destroy
    @kernal = Kernal.find(params[:id])
    @kernal.destroy
  end

  private
    def search_params
      qkey = ''
      Kernal.column_names.each do |e|
        if e != 'size' && e != 'permissions'
          qkey = qkey + e + '_or_'
        end
      end
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_kernal
      @kernal = Kernal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def kernal_params
      params.permit(:image, :forceGraph, :mixtape, :hypertext_id, :source_url_id, :signed_url, :signed_url_m, :signed_url_s, :signed_url_l, :file_type, :file_name, :file_path, :url, :size, :author, :time_posted, :time_scraped, :description, :key_words, :hashtags, :likes, :reposts)
    end
end
