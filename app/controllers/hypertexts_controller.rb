class HypertextsController < ApplicationController
  before_action :set_hypertext, only: %i[ show update destroy ]

  # GET /hypertexts
  def index
    @hypertexts = Hypertext.all

    render json: @hypertexts
  end

  # GET /hypertexts/1
  def show
    render json: @hypertext
  end

  # POST /hypertexts
  def create
    @hypertext = Hypertext.new(hypertext_params)

    if @hypertext.save
      render json: @hypertext, status: :created, location: @hypertext
    else
      render json: @hypertext.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /hypertexts/1
  def update
    if @hypertext.update(hypertext_params)
      render json: @hypertext
    else
      render json: @hypertext.errors, status: :unprocessable_entity
    end
  end

  # DELETE /hypertexts/1
  def destroy
    @hypertext.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hypertext
      @hypertext = Hypertext.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hypertext_params
      params.require(:hypertext)
      params.permit(:source_url_id,:url, :name, :scrape_interval, :time_last_scrape, :time_initial_scrape)
    end
end
