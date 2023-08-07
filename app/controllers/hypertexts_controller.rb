class HypertextsController < ApplicationController
  before_action :authenticate_user!
 
  # GET /hypertexts
  def index
    @q = Hypertext.ransack(search_params)
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    render json:  @q.result
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
    def search_params
      qkey = ''
      Hypertext.column_names.each { |e| qkey = qkey + e + '_or_' }
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_hypertext
      @hypertext = Hypertext.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hypertext_params
      params.require(:hypertext)
      params.permit(:logo_path, :source_url_id, :url, :name, :scrape_interval, :time_last_scrape, :time_initial_scrape)
    end
end
