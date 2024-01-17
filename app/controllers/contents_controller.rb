class ContentsController < ApplicationController
  before_action :authenticate_user!

  # GET /contents
  def index
    if (params.has_key?(:mix))
      @contents = Content.where(id: Mixtape.all.pluck(:contents)) 
      render json: @contents
    end
  end

  # GET /contents/1
  def show
    render json: @content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_content
      @content = Content.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def content_params
      params.require(:content).permit(:contains)
    end
end
