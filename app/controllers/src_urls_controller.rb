class SrcUrlsController < ApplicationController
  before_action :set_src_url, only: %i[ show update destroy ]

  # GET /src_urls
  def index
    @permited = SrcUrl.where("permissions @> ARRAY[?]::varchar[]", current_user.id)
    @q = @permited.ransack(search_params)
    @q.sorts = 'updated_at desc' 
    @pagy, @page = params.has_key?(:page) ? pagy(@q.result) : @q.result 
    render json: @page
  end

  # GET /src_urls/1
  def show
    render json: @src_url
  end

  # POST /src_urls
  def create
    @src_url = SrcUrl.new(src_url_params)

    if @src_url.save
      render json: @src_url, status: :created, location: @src_url
    else
      render json: @src_url.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /src_urls/1
  def update
    if @src_url.update(src_url_params)
      render json: @src_url
    else
      render json: @src_url.errors, status: :unprocessable_entity
    end
  end

  # DELETE /src_urls/1
  def destroy
    @src_url.destroy
  end

  private
    def search_params
      qkey = ''
      SrcUrl.column_names.each { |e| qkey = qkey + e + '_or_' }
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_src_url
      @src_url = SrcUrl.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def src_url_params
      params.require(:src_url).permit(:name, :url, :permissions[])
    end
end
