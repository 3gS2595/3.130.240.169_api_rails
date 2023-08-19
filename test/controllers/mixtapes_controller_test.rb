require "test_helper"

class MixtapesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mixtape = mixtapes(:one)
  end

  test "should get index" do
    get mixtapes_url, as: :json
    assert_response :success
  end

  test "should create mixtape" do
    assert_difference("Mixtape.count") do
      post mixtapes_url, params: { mixtape: { name: @mixtape.name } }, as: :json
    end

    assert_response :created
  end

  test "should show mixtape" do
    get mixtape_url(@mixtape), as: :json
    assert_response :success
  end

  test "should update mixtape" do
    patch mixtape_url(@mixtape), params: { mixtape: { name: @mixtape.name } }, as: :json
    assert_response :success
  end

  test "should destroy mixtape" do
    assert_difference("Mixtape.count", -1) do
      delete mixtape_url(@mixtape), as: :json
    end

    assert_response :no_content
  end
end
