require "test_helper"

class UserFeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_feed = user_feeds(:one)
  end

  test "should get index" do
    get user_feeds_url, as: :json
    assert_response :success
  end

  test "should create user_feed" do
    assert_difference("UserFeed.count") do
      post user_feeds_url, params: { user_feed: { feed_mixtape: @user_feed.feed_mixtape, feed_sources: @user_feed.feed_sources, folders: @user_feed.folders } }, as: :json
    end

    assert_response :created
  end

  test "should show user_feed" do
    get user_feed_url(@user_feed), as: :json
    assert_response :success
  end

  test "should update user_feed" do
    patch user_feed_url(@user_feed), params: { user_feed: { feed_mixtape: @user_feed.feed_mixtape, feed_sources: @user_feed.feed_sources, folders: @user_feed.folders } }, as: :json
    assert_response :success
  end

  test "should destroy user_feed" do
    assert_difference("UserFeed.count", -1) do
      delete user_feed_url(@user_feed), as: :json
    end

    assert_response :no_content
  end
end
