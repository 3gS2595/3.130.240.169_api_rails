class SourceUrlsController < ApplicationController
  before_action :authenticate_user!

  # GET /source_urls
  def index
    @q = SourceUrl.ransack(search_params)
    @q.sorts = params.has_key?(:sort) ? params[:sort] : null 
    render json:  @q.result
  end

  # GET /source_urls/1
  def show
    render json: @source_url
  end

  # POST /source_urls
  def create
    @source_url = SourceUrl.new(source_url_params)

    if @source_url.save
      render json: @source_url, status: :created, location: @source_url
    else
      render json: @source_url.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /source_urls/1
  def update
    if @source_url.update(source_url_params)
      render json: @source_url
    else
      render json: @source_url.errors, status: :unprocessable_entity
    end
  end

  # DELETE /source_urls/1
  def destroy
    @source_url.destroy
  end

  private
    def search_params
      qkey = ''
      SourceUrl.column_names.each { |e| qkey = qkey + e + '_or_' }
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_source_url
      @source_url = SourceUrl.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def source_url_params
      params.require(:source_url).permit(:domain, :tag_list, :source, :logo_path)
    end
end
