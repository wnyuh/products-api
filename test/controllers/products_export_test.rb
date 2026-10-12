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
end
