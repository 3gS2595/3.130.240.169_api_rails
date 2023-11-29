class SrcUrlSubsetsController < ApplicationController
  before_action :set_src_url_subset, only: %i[ show update destroy ]

  # GET /src_url_subsets
  def index
    @src_url_subsets = SrcUrlSubset.all

    render json: @src_url_subsets
  end

  # GET /src_url_subsets/1
  def show
    render json: @src_url_subset
  end

  # POST /src_url_subsets
  def create
    @src_url_subset = SrcUrlSubset.new(src_url_subset_params)

    if @src_url_subset.save
      render json: @src_url_subset, status: :created, location: @src_url_subset
    else
      render json: @src_url_subset.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /src_url_subsets/1
  def update
    if @src_url_subset.update(src_url_subset_params)
      render json: @src_url_subset
    else
      render json: @src_url_subset.errors, status: :unprocessable_entity
    end
  end

  # DELETE /src_url_subsets/1
  def destroy
    @src_url_subset.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_src_url_subset
      @src_url_subset = SrcUrlSubset.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def src_url_subset_params
      params.require(:src_url_subset).permit(:src_url_id, :url, :name, :scrape_interval, :time_last_scraped, :permissions[])
    end
end