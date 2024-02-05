class MixtapesController < ApplicationController
  before_action :authenticate_user!

  # GET /mixtapes
  def index
    @q = Mixtape.where(id: current_user.permission.mixtapes).joins(:content).order("contents.updated_at desc")
    render json: @q
  end

  # GET /mixtapes/1
  def show
    render json: @mixtape
  end

  # POST /mixtapes
  def create
    @mixtape = Mixtape.new(
      name: params[:name]
    )
    @newContents = Content.create(
      contains: []
    )
    @mixtape.update_attribute(:content_id, @newContents.id)
    new = current_user.permission.mixtapes
    new.push(@mixtape.id)
    current_user.permission.update(mixtapes: new)
    new = current_user.user_feed.feed_mixtape
    new.push(@mixtape.id)
    current_user.user_feed.update(feed_mixtape: new)
    if @mixtape.save
      render json: @mixtape
    else
      render json: @mixtape.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mixtapes/1
  def update
    @mixtape = Mixtape.find(params[:id])
    @mixtape.update(mixtape_params)
    Content.update(@mixtape.content.id, updated_at: DateTime.now())
    render json: @mixtape
  end

  # DELETE /mixtapes/1
  def destroy
    @mixtape = Mixtape.find(params[:id])
    Content.find(@mixtape.content_id).destroy
    new = current_user.permission.mixtapes
    new.delete(@mixtape.id)
    current_user.permission.update(mixtapes: new)
    @mixtape.destroy

  end

  private
    def search_params
      qkey = ''
      Mixtape.column_names.each { |e| qkey = qkey + e + '_or_' }
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_mixtape
      @mixtape = Mixtape.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mixtape_params
      params.permit(:name, :addKernal, :remKernal, :id, :content => [])
    end
end
