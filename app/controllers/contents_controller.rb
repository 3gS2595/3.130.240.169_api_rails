class ContentsController < ApplicationController
  before_action :authenticate_user!

  # GET /contents
  def index
    if (params.has_key?(:mix))
      @contents = Content.where("permissions @> ARRAY[?]::varchar[]", [current_user.id]).where(id: Mixtape.all.pluck(:contents)).order('updated_at desc') 
      render json: @contents
    end
  end

  # GET /contents/1
  def show
    render json: @content
  end

  # PATCH/PUT
  def update
    @content = Content.find(params[:id])
    if (params.has_key?(:kid) && params.has_key?(:add))
      new = @content.contains.append(params[:kid])
      Content.update(params[:id], :contains => new)
      @content = Content.where("permissions @> ARRAY[?]::varchar[]", [current_user.id]).where(id: Mixtape.all.pluck(:contents)).order('updated_at desc')
      render json: @content
    end
    if (params.has_key?(:kid) && params.has_key?(:remove))
      new = @content.contains
      new.delete(params[:kid])
      Content.update(params[:id], :contains => new)
      @content = Content.where("permissions @> ARRAY[?]::varchar[]", [current_user.id]).where(id: Mixtape.all.pluck(:contents)).order('updated_at desc')
      render json: @content
    end
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
