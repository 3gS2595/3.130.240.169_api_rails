class LinkContentsController < ApplicationController
  before_action :set_link_content, only: %i[ show update destroy ]

  # GET /link_contents
  def index
    @link_contents = LinkContent.all

    render json: @link_contents
  end

  # GET /link_contents/1
  def show
    render json: @link_content
  end

  # POST /link_contents
  def create
    @link_content = LinkContent.new(link_content_params)

    if @link_content.save
      render json: @link_content, status: :created, location: @link_content
    else
      render json: @link_content.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /link_contents/1
  def update
    if @link_content.update(link_content_params)
      render json: @link_content
    else
      render json: @link_content.errors, status: :unprocessable_entity
    end
  end

  # DELETE /link_contents/1
  def destroy
    @link_content.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link_content
      @link_content = LinkContent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def link_content_params
      params.require(:link_content).permit(:source_url_id, :names, :url, :word_count, :author, :text_body)
    end
end
