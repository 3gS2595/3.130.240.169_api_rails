class SrcUrlSubsetsController < ApplicationController
  before_action :authenticate_user!
  
  # GET /src_url_subsets
  def index
    @permited = SrcUrlSubset.where(id: current_user.permission.src_url_subsets).order("time_last_entry desc")
    render json: @permited
  end

  # GET /src_url_subsets/1
  def show
    render json: @src_url_subset
  end

  # POST /src_url_subsets
  def create
    if !SrcUrlSubset.exists?(url: params[:url])
      @newContents = Content.create(
        contains: []
      )
      @src_url_subset = SrcUrlSubset.create(
        name: params[:name],
        url: params[:url],
        content_id: @newContents.id
      )
      if (params.has_key?(:src_url_id))
        @src_url_subset.src_url_id = params[:src_url_id]
      else
        domain = /^(?:https?:\/\/)?(?:[^@\/\n]+@)?(?:www\.)?([^:\/?\n]+)/.match(params[:url])[1]
        @src_url_subset.src_url_id = SrcUrl.where(url: domain).first.id
      end
    else
      @src_url_subset = SrcUrlSubset.where(url: params[:url])
    end
    new = current_user.permission.src_url_subsets
    new.push(@src_url_subset.id)
    current_user.permission.update(src_url_subsets: new)
    new = current_user.user_feed.feed_sources
    new.push(@src_url_subset.id)
    current_user.user_feed.update(feed_sources: new)
    if @src_url_subset.save
      if (params[:url].include? "tumblr")
        Sidekiq.set_schedule(params[:name], { 'in' => ['2s'], 'class' => 'TumblrApiInit' })
      end
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
    new = user.permission.src_url_subsets
    new.delete()
    new.delete(@src_url_subset.id)
    user.permission.update(src_url_subsets: new)
  end

  private
    def search_params
      qkey = ''
      Mixtape.column_names.each { |e| qkey = qkey + e + '_or_' }
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_src_url_subset
      @src_url_subset = SrcUrlSubset.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def src_url_subset_params
      params.require(:src_url_subset).permit(:src_url_id, :url, :name, :scrape_interval, :time_last_scraped, :permissions[])
    end
end
