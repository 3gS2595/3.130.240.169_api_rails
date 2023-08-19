class KernalsController < ApplicationController
  before_action :authenticate_user!

  # GET /kernals
  def index
    Aws.use_bundled_cert!
    s3_client = Aws::S3::Client.new(
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      endpoint: 'https://nyc3.digitaloceanspaces.com',
      force_path_style: false,
      region: 'us-east-1'
    )
    signer = Aws::S3::Presigner.new(client: s3_client)
    @q = Kernal.ransack(search_params)
    puts(@q.result.length)
    @q.sorts = params[:sort] if @q.sorts.empty?
    puts('help')
    puts(@q.result.length)
    if (params.has_key?(:page))
      @page = @q.result.page(params[:page])
    else 
      @page = @q.result
    end
    @page.each do |kernal|
      if !kernal.file_path.nil?
        if kernal.file_path.length > 0
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
          kernal.assign_attributes({ :signed_url => url})
          kernal.assign_attributes({ :signed_url_nail => url_nail})
        end
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
    uploader = TaskFileUploader.new(@kernal) 
    File.open(params[:image]) do |file|
      puts(file)
     uploader.store!(file)
    end 
    if @kernal.save
      render json: @kernal, status: :created, location: @kernal
    else
      render json: @kernal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /kernals/1
  def update
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
