class KernalsController < ApplicationController
  before_action :authenticate_user!
  require "selenium-webdriver"
  
  # GET
  def index
    if !params.has_key?(:forceGraph)

      if (!params.has_key?(:src_url_subset_id))
        if params.has_key?(:mixtape)
          # fetch specific mixtape's kernals
          @q = Kernal.order(time_posted: :desc).where(id: Mixtape.find(params[:mixtape]).content.contains)
        else
          # fetch kernals in any mixtape
          @q = Kernal.order(time_posted: :desc).where(id: Mixtape.where(id: current_user.user_feed.feed_mixtape).joins(:content).pluck(:'contents.contains').flatten)
        end

      else 
        if(params[:src_url_subset_id] != "-1")
          # fetch specific src_url_subset's kernals 
          @q = Kernal.order(time_posted: :desc).where(id: SrcUrlSubset.find(params[:src_url_subset_id]).content.contains)
        else
          @q = Kernal.order(time_posted: :desc).where(id: SrcUrlSubset.where(id: current_user.user_feed.feed_sources).joins(:content).pluck(:'contents.contains').flatten)
        end
      end; nil

      # search, paginates selected kernals

      # page, search, and presign media
      @q = params.has_key?(:q) ? @q.ransack(search_params).result : @q
      @page = @q.page(params[:page]).per(@page_size)
      signer = Aws::Sigv4::Signer.new(
        service: "s3",
        access_key_id: Rails.application.credentials.aws[:access_key_id],
        secret_access_key: Rails.application.credentials.aws[:secret_access_key],
        region: 'us-east-1'
      )
      @page.each do |kernal|
        if !kernal.file_path.nil? && kernal.file_path.length > 0  && kernal.signed_url.nil?
          key = kernal.file_path
          nailKey = kernal.file_path

          if kernal.file_type == ".pdf"
            key = kernal.id + ".pdf"
            nailKey = kernal.id + ".avif"
          end
          kernal.assign_attributes({ 
            :signed_url => 
              signer.presign_url(
                http_method: "GET",
                url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
                expires_in: 600,
                body_digest: "UNSIGNED-PAYLOAD"
              ),
            :signed_url_s => 
              signer.presign_url(
                http_method: "GET",
                url: "https://crystal-hair-s.nyc3.digitaloceanspaces.com/s_160_#{nailKey}",
                expires_in: 600,
                body_digest: "UNSIGNED-PAYLOAD"
              ), 
            :signed_url_m => 
              signer.presign_url(
                http_method: "GET",
                url: "https://crystal-hair-m.nyc3.digitaloceanspaces.com/m_400_#{nailKey}",
                expires_in: 600,
                body_digest: "UNSIGNED-PAYLOAD"
              ),
            :signed_url_l => 
              signer.presign_url(
                http_method: "GET",
                url: "https://crystal-hair-l.nyc3.digitaloceanspaces.com/l_1000_#{nailKey}",
                expires_in: 600,
                body_digest: "UNSIGNED-PAYLOAD"
              )
          })      
        end
      end
      render json: @page
    else
      # fetches forceGraph data
      if params.has_key?(:mixtape)
        @q = Kernal.where(id: Mixtape.find(params[:mixtape]).content.contains)
      else
        # fetch kernals in any mixtape
        @q = Kernal.where(id: Mixtape.where(id: current_user.permission.mixtapes).joins(:content).pluck(:'contents.contains').flatten)
      end
      @page = @q 
      render json: @page.as_json(only: [:id, :file_type])
    end; nil
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
      File.open(params[:image]) do |file| 
        if (params[:image].original_filename.include?("gif"))
            uploader = GifUploader.new(@kernal)
            uploader.store!(file) 
          else
            uploader = ImageUploader.new(@kernal)
            uploader.store!(file) 
          end
      end
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
      @content = Mixtape.find(params[:mixtape]).content
      new = @content.contains.append(@kernal.id)
      Content.update(@content.id, :contains => new)
    end
    if params.has_key?(:url) 
      puts(params[:url])
      options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
      driver = Selenium::WebDriver.for(:firefox, options: options) 
      driver.manage.window.resize_to(1080, 1080)
      driver.navigate.to params[:url]
      sleep(3) 
      @kernal.update_attribute(:url, params[:url])
      driver.save_screenshot("selenium.png")
      driver.quit
      file = File.open("./selenium.png")
      uploader = ImageUploader.new(@kernal)
      uploader.store!(file)
    end
    @kernal.save

    # presign urls
    if !@kernal.file_path.nil? && @kernal.file_path.length > 0
      key = @kernal.file_path
      nailKey = @kernal.file_path
      if @kernal.file_type == ".pdf"
        key = @kernal.id + ".pdf"
        nailKey = @kernal.id + ".avif"
      end

      signer = Aws::Sigv4::Signer.new(
        service: "s3",
        access_key_id: Rails.application.credentials.aws[:access_key_id],
        secret_access_key: Rails.application.credentials.aws[:secret_access_key],
        region: 'us-east-1'
      )
      @kernal.assign_attributes({ 
        :signed_url => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          ),
        :signed_url_s => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-s.nyc3.digitaloceanspaces.com/s_160_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          ), 
        :signed_url_m => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-m.nyc3.digitaloceanspaces.com/m_400_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          ),
        :signed_url_l => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-l.nyc3.digitaloceanspaces.com/l_1000_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
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
    Mixtape.where(id: current_user.permission.mixtapes).each do |mix|
      if mix.content.contains.include? params[:id]
        new = mix.content.contains
        new.delete(params[:id]) 
        Content.update(mix.content.id, :contains => new)
      end
    end
    SrcUrlSubset.where(id: current_user.permission.src_url_subsets).each do |src|
      if src.content.contains.include? params[:id]
        new = src.content.contains 
        new.delete(params[:id])
        Content.update(src.content.id, :contains => new)
      end
    end
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
      params.permit(
        :image, 
        :forceGraph, 
        :src_url_subset_id, 
        :src_url_subset_assigned_id,
        :mixtape, 
        :hypertext_id, 
        :source_url_id, 
        :signed_url, 
        :signed_url_m, 
        :signed_url_s, 
        :signed_url_l, 
        :file_type, 
        :file_name, 
        :file_path, 
        :url, 
        :size, 
        :author, 
        :description,
        :time_posted, 
        :time_scraped, 
        :description, 
        :key_words, 
        :hashtags, 
        :likes, 
        :reposts,
        :id,
      )
    end
end
