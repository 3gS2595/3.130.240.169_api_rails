class SrcUrlsController < ApplicationController
  before_action :set_src_url, only: %i[ show update destroy ]

  # GET /src_urls
  def index
    @src_urls = SrcUrl.all

    render json: @src_urls
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
    # Use callbacks to share common setup or constraints between actions.
    def set_src_url
      @src_url = SrcUrl.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def src_url_params
      params.require(:src_url).permit(:name, :url, :permissions[])
    end
end
