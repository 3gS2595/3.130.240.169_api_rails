class UserFeedsController < ApplicationController
  before_action :authenticate_user!

  # GET /user_feeds
  def index
      @contents = current_user.user_feed
      render json: @contents
  end

  # POST /user_feeds
  def create
    @feed = nil
    if current_user.user_feed_id == nil
      @feed = UserFeed.create(
        feed_mixtape: [],
        feed_sources: [],
        folders: []
      )
      User.update(current_user.id, :user_feed_id => @feed.id)
    else
      @feed = UserFeed.find(current_user.user_feed_id)
    end
    puts @feed.id
    if (params.has_key?(:mid) && params.has_key?(:add))
      new = @feed.feed_mixtape.append(params[:mid])
      UserFeed.update(@feed.id, :feed_mixtape => new)
      render json: @feed
    end
    if (params.has_key?(:mid) && params.has_key?(:remove))
      new = @feed.feed_mixtape
      new.delete(params[:mid])
      UserFeed.update(@feed.id, :feed_mixtape => new)
      render json: @feed
    end
    if (params.has_key?(:sid) && params.has_key?(:add))
      new = @feed.feed_sources.append(params[:sid])
      UserFeed.update(@feed.id, :feed_sources => new)
      render json: @feed
    end
    if (params.has_key?(:sid) && params.has_key?(:remove))
      new = @feed.feed_sources
      new.delete(params[:sid])
      UserFeed.update(@feed.id, :feed_sources => new)
      render json: @feed
    end
  end

  # DELETE /user_feeds/1
  def destroy
    @user_feed.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_feed
      @user_feed = UserFeed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_feed_params
      params.require(:user_feed).permit(:folders, :feed_mixtape, :feed_sources)
    end
end
