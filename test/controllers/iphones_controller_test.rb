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

  test "create với dữ liệu sai trả 422 và không tạo bản ghi" do
    assert_no_difference("Iphone.count") do
      post iphones_url, params: { iphone: { name: "", storage: "256GB", price: "abc" } }, as: :json
    end

    assert_response :unprocessable_content
    errors = response.parsed_body
    assert errors.key?("name")
    assert errors.key?("storage")
    assert errors.key?("price")
  end

  test "create với storage vượt giới hạn trả 422 chứ không phải 500" do
    assert_no_difference("Iphone.count") do
      post iphones_url, params: { iphone: { name: "x", storage: 10**30, price: 1 } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "update với dữ liệu sai trả 422 và giữ nguyên bản ghi" do
    patch iphone_url(@iphone), params: { iphone: { price: -5 } }, as: :json

    assert_response :unprocessable_content
    assert_equal 9.99, @iphone.reload.price.to_f
  end
end
