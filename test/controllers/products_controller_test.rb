require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url, as: :json
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { category: @product.category, description: @product.description, name: @product.name, price: @product.price } }, as: :json
    end

    assert_response :created
  end

  test "should show product" do
    get product_url(@product), as: :json
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { category: @product.category, description: @product.description, name: @product.name, price: @product.price } }, as: :json
    assert_response :success
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product), as: :json
    end

    assert_response :no_content
  end

  test "create với dữ liệu sai trả 422 và không tạo bản ghi" do
    assert_no_difference("Product.count") do
      post products_url, params: { product: { name: "", price: "abc", category: "Ốp lưng" } }, as: :json
    end

    assert_response :unprocessable_content
    errors = response.parsed_body
    assert errors.key?("name")
    assert errors.key?("price")
    assert errors.key?("category")
  end

  test "create chuẩn hóa category về chữ thường" do
    post products_url, params: { product: { name: "Cáp USB-C", price: 120_000, category: "  Cable " } }, as: :json

    assert_response :created
    assert_equal "cable", response.parsed_body["category"]
  end

  test "update với dữ liệu sai trả 422 và giữ nguyên bản ghi" do
    patch product_url(@product), params: { product: { price: -5 } }, as: :json

    assert_response :unprocessable_content
    assert_equal 350_000, @product.reload.price
  end

  test "show id không tồn tại trả 404" do
    get product_url(id: 0), as: :json

    assert_response :not_found
  end
end
