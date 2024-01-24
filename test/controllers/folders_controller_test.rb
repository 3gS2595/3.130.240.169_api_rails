require "test_helper"

class FoldersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @folder = folders(:one)
  end

  test "should get index" do
    get folders_url, as: :json
    assert_response :success
  end

  test "should create folder" do
    assert_difference("Folder.count") do
      post folders_url, params: { folder: { contains: @folder.contains, name: @folder.name } }, as: :json
    end

    assert_response :created
  end

  test "should show folder" do
    get folder_url(@folder), as: :json
    assert_response :success
  end

  test "should update folder" do
    patch folder_url(@folder), params: { folder: { contains: @folder.contains, name: @folder.name } }, as: :json
    assert_response :success
  end

  test "should destroy folder" do
    assert_difference("Folder.count", -1) do
      delete folder_url(@folder), as: :json
    end

    assert_response :no_content
  end
end
