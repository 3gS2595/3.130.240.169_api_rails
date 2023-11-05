class KernalsController < ApplicationController
  before_action :authenticate_user!
  
  # GET
  def index
    if !params.has_key?(:forceGraph)
      @q = params.has_key?(:mixtape) ? Kernal.where(id: Mixtape.find(params[:mixtape]).content) : Kernal
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
              key = kernal.file_path + ".pdf"
              nailKey = kernal.file_path + ".avif"
            end
          url = signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
          url_nail = signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-nail.nyc3.digitaloceanspaces.com/nail_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
          kernal.assign_attributes({ :signed_url => url, :signed_url_nail => url_nail})
        end
      end
    else
      @page = params.has_key?(:mixtape) ? Kernal.where(id: Mixtape.find(params[:mixtape]).content) : Kernal.all
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
      time_posted: DateTime.now()
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
      File.open(params[:pdf]) do |file| 
        uploader.store!(file) end
    end
    if (params.has_key?(:text))
      @kernal.update_attribute(:description, params[:text])
    end

    if params.has_key?(:mixtape) 
      @mixtape = Mixtape.find(params[:mixtape])
      @mixtape.update(content: @mixtape.content.push(@kernal.id))
    end

    if @kernal.save
      render json: @kernal, status: :created, location: @kernal
    else
      render json: @kernal.errors, status: :unprocessable_entity
    end
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
        if e != 'size'
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
      params.permit(:image, :forceGraph, :mixtape, :hypertext_id, :source_url_id, :signed_url, :signed_url_nail, :file_type, :file_name, :file_path, :url, :size, :author, :time_posted, :time_scraped, :description, :key_words, :hashtags, :likes, :reposts)
    end
end
