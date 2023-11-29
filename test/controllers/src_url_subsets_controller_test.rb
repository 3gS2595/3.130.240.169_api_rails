require "test_helper"

class SrcUrlSubsetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @src_url_subset = src_url_subsets(:one)
  end

  test "should get index" do
    get src_url_subsets_url, as: :json
    assert_response :success
  end

  test "should create src_url_subset" do
    assert_difference("SrcUrlSubset.count") do
      post src_url_subsets_url, params: { src_url_subset: { name: @src_url_subset.name, permissions[]: @src_url_subset.permissions[], scrape_interval: @src_url_subset.scrape_interval, src_url_id: @src_url_subset.src_url_id, time_last_scraped: @src_url_subset.time_last_scraped, url: @src_url_subset.url } }, as: :json
    end

    assert_response :created
  end

  test "should show src_url_subset" do
    get src_url_subset_url(@src_url_subset), as: :json
    assert_response :success
  end

  test "should update src_url_subset" do
    patch src_url_subset_url(@src_url_subset), params: { src_url_subset: { name: @src_url_subset.name, permissions[]: @src_url_subset.permissions[], scrape_interval: @src_url_subset.scrape_interval, src_url_id: @src_url_subset.src_url_id, time_last_scraped: @src_url_subset.time_last_scraped, url: @src_url_subset.url } }, as: :json
    assert_response :success
  end

  test "should destroy src_url_subset" do
    assert_difference("SrcUrlSubset.count", -1) do
      delete src_url_subset_url(@src_url_subset), as: :json
    end

    assert_response :no_content
  end
end
