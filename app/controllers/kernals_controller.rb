class KernalsController < ApplicationController
  before_action :authenticate_user!

  # GET /kernals
  def index
    # collect search sort
    @q = Kernal.all
    if (params.has_key?(:mixtape)) { @q = @q.where(id: params[:mixtape].split(',')) }
    if (params.has_key?(:q)) { @q = @q.ransack(search_params) }
    if (params.has_key?(:sort)) { @q.sorts = params[:sort] }
    
    # pagination
    @page = @q.result
    if (params.has_key?(:page)) { @page = @page.page(params[:page]) }
 
    # presign urls
    Aws.use_bundled_cert!
    s3_client = Aws::S3::Client.new(
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      endpoint: 'https://nyc3.digitaloceanspaces.com',
      region: 'us-east-1'
    )
    signer = Aws::S3::Presigner.new(client: s3_client)
    @page.each do |kernal|
      if !kernal.file_path.nil?
        url = signer.presigned_url(
          :get_object,
          bucket: "crystal-hair",
          key: kernal.file_path,
          expires_in: 300
        )
        url_nail = signer.presigned_url(
          :get_object,
          bucket: "crystal-hair-nail",
          key: "nail_" + kernal.file_path,
          expires_in: 300
        )
        kernal.assign_attributes({ :signed_url => url, :signed_url_nail => url_nail})
      end
    end
    render json:  @page
  end

  # GET /kernals/1
  def show
    @kernal = Kernal.find(params[:id])
    render json: @kernal
  end

  # POST /kernals
  def create
    @kernal = Kernal.new(kernal_params)
    if (params.has_key?(:image))
      @kernal.assign_attributes({
        :file_path => SecureRandom.uuid + params[:file_type]
      })
      uploader = TaskFileUploader.new(@kernal) 
      File.open(params[:image]) do |file| { uploader.store!(file) }
    end
    if @kernal.save
      render json: @kernal, status: :created, location: @kernal
    else
      render json: @kernal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /kernals/1
  def update
    @kernal = Kernal.find(params[:id])
    if @kernal.update(kernal_params)
      render json: @kernal
    else
      render json: @kernal.errors, status: :unprocessable_entity
    end
  end

  # DELETE /kernals/1
  def destroy
    @kernal = Kernal.find(params[:id])
    @kernal.destroy
  end

  private
    def search_params
      qkey = ''
      Kernal.column_names.each { |e| qkey = qkey + e + '_or_' }
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_kernal
      @kernal = Kernal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def kernal_params
      params.permit(:hypertext_id, :source_url_id, :signed_url, :signed_url_nail, :file_type, :file_name, :file_path, :url, :size, :author, :time_posted, :time_scraped, :description, :key_words, :hashtags, :likes, :reposts)
    end
end
