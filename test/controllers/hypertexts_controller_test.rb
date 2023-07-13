require "test_helper"

class HypertextsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hypertext = hypertexts(:one)
  end

  test "should get index" do
    get hypertexts_url, as: :json
    assert_response :success
  end

  test "should create hypertext" do
    assert_difference("Hypertext.count") do
      post hypertexts_url, params: { hypertext: { name: @hypertext.name, scrape_interval: @hypertext.scrape_interval, time_initial_scrape: @hypertext.time_initial_scrape, time_last_scrape: @hypertext.time_last_scrape, url: @hypertext.url } }, as: :json
    end

    assert_response :created
  end

  test "should show hypertext" do
    get hypertext_url(@hypertext), as: :json
    assert_response :success
  end

  test "should update hypertext" do
    patch hypertext_url(@hypertext), params: { hypertext: { name: @hypertext.name, scrape_interval: @hypertext.scrape_interval, time_initial_scrape: @hypertext.time_initial_scrape, time_last_scrape: @hypertext.time_last_scrape, url: @hypertext.url } }, as: :json
    assert_response :success
  end

  test "should destroy hypertext" do
    assert_difference("Hypertext.count", -1) do
      delete hypertext_url(@hypertext), as: :json
    end

    assert_response :no_content
  end
end
