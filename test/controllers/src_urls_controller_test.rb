require "test_helper"

class SrcUrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @src_url = src_urls(:one)
  end

  test "should get index" do
    get src_urls_url, as: :json
    assert_response :success
  end

  test "should create src_url" do
    assert_difference("SrcUrl.count") do
      post src_urls_url, params: { src_url: { name: @src_url.name, permissions[]: @src_url.permissions[], url: @src_url.url } }, as: :json
    end

    assert_response :created
  end

  test "should show src_url" do
    get src_url_url(@src_url), as: :json
    assert_response :success
  end

  test "should update src_url" do
    patch src_url_url(@src_url), params: { src_url: { name: @src_url.name, permissions[]: @src_url.permissions[], url: @src_url.url } }, as: :json
    assert_response :success
  end

  test "should destroy src_url" do
    assert_difference("SrcUrl.count", -1) do
      delete src_url_url(@src_url), as: :json
    end

    assert_response :no_content
  end
end
