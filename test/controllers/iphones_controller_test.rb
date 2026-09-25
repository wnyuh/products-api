require "test_helper"

class IphonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @iphone = iphones(:one)
  end

  test "should get index" do
    get iphones_url, as: :json
    assert_response :success
  end

  test "should create iphone" do
    assert_difference("Iphone.count") do
      post iphones_url, params: { iphone: { color: @iphone.color, name: @iphone.name, price: @iphone.price, storage: @iphone.storage } }, as: :json
    end

    assert_response :created
  end

  test "should show iphone" do
    get iphone_url(@iphone), as: :json
    assert_response :success
  end

  test "should update iphone" do
    patch iphone_url(@iphone), params: { iphone: { color: @iphone.color, name: @iphone.name, price: @iphone.price, storage: @iphone.storage } }, as: :json
    assert_response :success
  end

  test "should destroy iphone" do
    assert_difference("Iphone.count", -1) do
      delete iphone_url(@iphone), as: :json
    end

    assert_response :no_content
  end
end
