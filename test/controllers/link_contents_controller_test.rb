require "test_helper"

class LinkContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @link_content = link_contents(:one)
  end

  test "should get index" do
    get link_contents_url, as: :json
    assert_response :success
  end

  test "should create link_content" do
    assert_difference("LinkContent.count") do
      post link_contents_url, params: { link_content: { author: @link_content.author, names: @link_content.names, text_body: @link_content.text_body, url: @link_content.url, word_count: @link_content.word_count } }, as: :json
    end

    assert_response :created
  end

  test "should show link_content" do
    get link_content_url(@link_content), as: :json
    assert_response :success
  end

  test "should update link_content" do
    patch link_content_url(@link_content), params: { link_content: { author: @link_content.author, names: @link_content.names, text_body: @link_content.text_body, url: @link_content.url, word_count: @link_content.word_count } }, as: :json
    assert_response :success
  end

  test "should destroy link_content" do
    assert_difference("LinkContent.count", -1) do
      delete link_content_url(@link_content), as: :json
    end

    assert_response :no_content
  end
end
