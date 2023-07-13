require "test_helper"

class KernalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kernal = kernals(:one)
  end

  test "should get index" do
    get kernals_url, as: :json
    assert_response :success
  end

  test "should create kernal" do
    assert_difference("Kernal.count") do
      post kernals_url, params: { kernal: { author: @kernal.author, description: @kernal.description, file_name: @kernal.file_name, file_path: @kernal.file_path, file_type: @kernal.file_type, hashtags: @kernal.hashtags, key_words: @kernal.key_words, likes: @kernal.likes, reposts: @kernal.reposts, size: @kernal.size, time_posted: @kernal.time_posted, time_scraped: @kernal.time_scraped, url: @kernal.url } }, as: :json
    end

    assert_response :created
  end

  test "should show kernal" do
    get kernal_url(@kernal), as: :json
    assert_response :success
  end

  test "should update kernal" do
    patch kernal_url(@kernal), params: { kernal: { author: @kernal.author, description: @kernal.description, file_name: @kernal.file_name, file_path: @kernal.file_path, file_type: @kernal.file_type, hashtags: @kernal.hashtags, key_words: @kernal.key_words, likes: @kernal.likes, reposts: @kernal.reposts, size: @kernal.size, time_posted: @kernal.time_posted, time_scraped: @kernal.time_scraped, url: @kernal.url } }, as: :json
    assert_response :success
  end

  test "should destroy kernal" do
    assert_difference("Kernal.count", -1) do
      delete kernal_url(@kernal), as: :json
    end

    assert_response :no_content
  end
end
