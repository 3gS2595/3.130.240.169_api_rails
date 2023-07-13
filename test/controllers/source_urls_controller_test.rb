require "test_helper"

class SourceUrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @source_url = source_urls(:one)
  end

  test "should get index" do
    get source_urls_url, as: :json
    assert_response :success
  end

  test "should create source_url" do
    assert_difference("SourceUrl.count") do
      post source_urls_url, params: { source_url: { domain: @source_url.domain, logo_path: @source_url.logo_path, source: @source_url.source, tag_list: @source_url.tag_list } }, as: :json
    end

    assert_response :created
  end

  test "should show source_url" do
    get source_url_url(@source_url), as: :json
    assert_response :success
  end

  test "should update source_url" do
    patch source_url_url(@source_url), params: { source_url: { domain: @source_url.domain, logo_path: @source_url.logo_path, source: @source_url.source, tag_list: @source_url.tag_list } }, as: :json
    assert_response :success
  end

  test "should destroy source_url" do
    assert_difference("SourceUrl.count", -1) do
      delete source_url_url(@source_url), as: :json
    end

    assert_response :no_content
  end
end
