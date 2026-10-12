require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "index trả mọi category, sắp theo name" do
    get categories_url, as: :json

    assert_response :success
    assert_equal [ "Cáp sạc", "Củ sạc", "Ốp lưng" ], response.parsed_body.map { |c| c["name"] }
  end

  test "show trả đúng category" do
    get category_url(categories(:case)), as: :json

    assert_response :success
    assert_equal "case", response.parsed_body["slug"]
  end

  test "show id không tồn tại trả 404" do
    get category_url(id: 0), as: :json

    assert_response :not_found
  end

  test "create tạo category mới trả 201 và Location" do
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "Máy tính bảng", slug: "tablet" } }, as: :json
    end

    assert_response :created
    assert_equal "tablet", response.parsed_body["slug"]
    assert_match %r{/categories/\d+\z}, response.headers["Location"]
  end

  test "create với dữ liệu sai trả 422 và không tạo bản ghi" do
    assert_no_difference("Category.count") do
      post categories_url, params: { category: { name: "", slug: "Bad Slug" } }, as: :json
    end

    assert_response :unprocessable_content
    assert response.parsed_body.key?("name")
    assert response.parsed_body.key?("slug")
  end

  test "create slug trùng trả 422" do
    post categories_url, params: { category: { name: "Khác", slug: "case" } }, as: :json

    assert_response :unprocessable_content
    assert response.parsed_body.key?("slug")
  end

  test "update đổi name" do
    patch category_url(categories(:case)), params: { category: { name: "Ốp lưng iPhone" } }, as: :json

    assert_response :success
    assert_equal "Ốp lưng iPhone", categories(:case).reload.name
  end

  test "update với dữ liệu sai trả 422 và giữ nguyên bản ghi" do
    patch category_url(categories(:case)), params: { category: { slug: "Bad Slug" } }, as: :json

    assert_response :unprocessable_content
    assert_equal "case", categories(:case).reload.slug
  end

  test "destroy category không có sản phẩm trả 204" do
    empty = Category.create!(name: "Trống", slug: "empty")

    assert_difference("Category.count", -1) do
      delete category_url(empty), as: :json
    end

    assert_response :no_content
  end

  test "destroy category còn sản phẩm trả 422, không xoá category lẫn sản phẩm" do
    category = categories(:charger)

    assert_no_difference([ "Category.count", "Product.count" ]) do
      delete category_url(category), as: :json
    end

    assert_response :unprocessable_content
    assert_includes response.parsed_body["base"].join, "dependent products exist"
  end
end
