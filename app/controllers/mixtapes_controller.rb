class MixtapesController < ApplicationController
  before_action :authenticate_user!

  # GET /mixtapes
  def index
    @permited = Mixtape.where("permissions @> ARRAY[?]::varchar[]", current_user.id)
    @q = @permited.ransack(search_params)
    @q.sorts = 'updated_at desc' 
    @page = params.has_key?(:page) ? @q.result.page(params[:page]).per(50) : @q.result 
    render json: @page
  end

  # GET /mixtapes/1
  def show
    render json: @mixtape
  end

  # POST /mixtapes
  def create
    uuid = SecureRandom.uuid
    @mixtape = Mixtape.new(
      name: params[:name],
      permissions: [current_user.id],
      include_in_feed: params[:include_in_feed]
    )
    @mixtape.id = uuid
    @newContents = Content.create(
      contains: [],
      permissions: @mixtape.permissions
    )
    @mixtape.update_attribute(:contents, @newContents.id)
    if @mixtape.save
      render json: @mixtape, status: :created, location: @mixtape
    else
      render json: @mixtape.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mixtapes/1
  def update
    @mixtape = Mixtape.find(params[:id])
    if (params.has_key?(:addKernal))
      @mixtape.update(content: @mixtape.content.push(params[:addKernal]))
    elsif (params.has_key?(:remKernal))
      @mixtape.update(content: @mixtape.content.select! { |el| el != params[:remKernal] })
    else
      @mixtape.update(mixtape_params)
    end
    render json: @mixtape
  end

  # DELETE /mixtapes/1
  def destroy
    @mixtape = Mixtape.find(params[:id])
    Content.find(@mixtape.contents).destroy
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
