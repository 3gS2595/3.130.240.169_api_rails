class MixtapesController < ApplicationController
  before_action :authenticate_user!

  # GET /mixtapes
  def index
    @q = Mixtape.ransack(search_params)

    if (params.has_key?(:sort))
      @q.sorts = params[:sort] if @q.sorts.empty?
    end 
    @page = @q.result
    if (params.has_key?(:page))
      @page = @page.page(params[:page])
    end
    render json: @page
  end

  # GET /mixtapes/1
  def show
    render json: @mixtape
  end

  # POST /mixtapes
  def create
    @mixtape = Mixtape.new(mixtape_params)
    if @mixtape.save
      render json: @mixtape, status: :created, location: @mixtape
    else
      render json: @mixtape.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mixtapes/1
  def update
    @mixtape = Mixtape.find(params[:id])
    if @mixtape.update(mixtape_params)
      render json: @mixtape
    else
      render json: @mixtape.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mixtapes/1
  def destroy
    @mixtape = mixtape.find(params[:id])
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
      params.permit(:name, :id, :content => [])
    end
end
