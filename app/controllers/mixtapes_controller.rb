class MixtapesController < ApplicationController
  before_action :set_mixtape, only: %i[ show update destroy ]

  # GET /mixtapes
  def index
    @mixtapes = Mixtape.all

    render json: @mixtapes
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
    if @mixtape.update(mixtape_params)
      render json: @mixtape
    else
      render json: @mixtape.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mixtapes/1
  def destroy
    @mixtape.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mixtape
      @mixtape = Mixtape.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mixtape_params
      params.require(:mixtape).permit(:name)
    end
end
