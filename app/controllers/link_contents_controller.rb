class LinkContentsController < ApplicationController
  before_action :set_link_content, only: %i[ show update destroy ]

  # GET /link_contents
  def index
    @q = LinkContent.ransack(search_params)
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    render json:  @q.result
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
    def search_params
      key = ""
      LinkContent.column_names.each do |e|
        key = key + e + "_or_"
        end
      key.chomp('_or_')
      key = key + "_cont"
      default_params = {key => params[:q]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_link_content
      @link_content = LinkContent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def link_content_params
      params.require(:link_content).permit(:post_date, :source_url_id, :names, :url, :word_count, :author, :text_body)
    end
end
