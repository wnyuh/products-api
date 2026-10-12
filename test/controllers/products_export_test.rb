require "test_helper"
require "csv"

# Kiểm thử GET /products/export: route, xác thực JWT, và nội dung file CSV
class ProductsExportTest < ActionDispatch::IntegrationTest
  setup do
    user = User.create!(name: "Tester", email: "tester@example.com", password: "secret1", confirmed: true)
    @auth = { "Authorization" => "Bearer #{JsonWebToken.encode(sub: user.id)}" }
  end

  test "route /products/export đi tới action export, không bị show nuốt" do
    assert_routing({ method: "get", path: "/products/export" }, { controller: "products", action: "export" })
  end

  test "thiếu token trả 401" do
    get export_products_url
    assert_response :unauthorized
  end

  test "có token trả file CSV với header đúng và tải xuống" do
    get export_products_url, headers: @auth

    assert_response :ok
    assert_match %r{text/csv}, response.content_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_match(/products-\d{4}-\d{2}-\d{2}\.csv/, response.headers["Content-Disposition"])

    body = CSV.parse(response.body.delete_prefix(ProductCsvExporter::BOM), headers: true)
    assert_equal ProductCsvExporter::HEADERS, body.headers
    assert_equal Product.count, body.size
  end

  # Lấy các dòng CSV từ response (bỏ BOM trước khi parse)
  def csv_rows
    CSV.parse(response.body.delete_prefix(ProductCsvExporter::BOM), headers: true)
  end

  test "lọc theo category giống index" do
    get export_products_url, params: { category: "case" }, headers: @auth

    assert_equal [ "case" ], csv_rows.map { |r| r["category"] }
  end

  test "lọc theo khoảng giá giống index" do
    get export_products_url, params: { max_price: 400_000 }, headers: @auth
    assert_equal [ products(:one).id.to_s ], csv_rows.map { |r| r["id"] }

    get export_products_url, params: { min_price: 400_000 }, headers: @auth
    assert_equal [ products(:two).id.to_s ], csv_rows.map { |r| r["id"] }
  end

  test "tìm theo q không phân biệt dấu giống index" do
    products(:two).save! # fixture không chạy before_save nên name_search còn NULL; save! để điền name_search
    get export_products_url, params: { q: "Sạc" }, headers: @auth

    assert_equal [ products(:two).id.to_s ], csv_rows.map { |r| r["id"] }
  end

  test "tham số lọc không hợp lệ trả 400" do
    get export_products_url, params: { min_price: "abc" }, headers: @auth

    assert_response :bad_request
  end
end
