require "test_helper"

# Kiểm thử GET /products: phân trang, sắp xếp, lọc
class ProductsIndexTest < ActionDispatch::IntegrationTest
  # Không dùng `as: :json` cho GET có params: helper sẽ gửi thành POST thay vì query string
  ACCEPT_JSON = { "Accept" => "application/json" }.freeze

  setup do
    Product.delete_all
    [
      { name: "Ốp trong suốt 13", price: 100_000, category: "case" },
      { name: "Ốp chống sốc 14", price: 200_000, category: "case" },
      { name: "Sạc nhanh 20W", price: 500_000, category: "charger" },
      { name: "Cáp USB-C 1m", price: 150_000, category: "cable" },
      { name: "Sạc không dây", price: 700_000, category: "charger" }
    ].each { |attrs| Product.create!(attrs) }
  end

  def names
    response.parsed_body.map { |p| p["name"] }
  end

  # --- phân trang ---

  test "mặc định trả toàn bộ (dưới 20 bản ghi) kèm header phân trang" do
    get products_url, headers: ACCEPT_JSON

    assert_response :success
    assert_equal 5, response.parsed_body.size
    assert_equal "5", response.headers["X-Total-Count"]
    assert_equal "1", response.headers["X-Page"]
    assert_equal "20", response.headers["X-Per-Page"]
  end

  test "per_page và page chia trang đúng" do
    get products_url, params: { per_page: 2, page: 2, sort: "price" }, headers: ACCEPT_JSON

    assert_equal [ "Ốp chống sốc 14", "Sạc nhanh 20W" ], names
    assert_equal "5", response.headers["X-Total-Count"]
    link = response.headers["Link"]
    assert_includes link, 'rel="first"'
    assert_includes link, 'rel="prev"'
    assert_includes link, 'rel="next"'
    assert_includes link, 'rel="last"'
  end

  test "trang cuối không có rel next, trang đầu không có rel prev" do
    get products_url, params: { per_page: 2, page: 3 }, headers: ACCEPT_JSON
    assert_not_includes response.headers["Link"], 'rel="next"'

    get products_url, params: { per_page: 2, page: 1 }, headers: ACCEPT_JSON
    assert_not_includes response.headers["Link"], 'rel="prev"'
  end

  test "per_page bị chặn tối đa 100 và tối thiểu 1" do
    get products_url, params: { per_page: 1000 }, headers: ACCEPT_JSON
    assert_equal "100", response.headers["X-Per-Page"]

    get products_url, params: { per_page: 0 }, headers: ACCEPT_JSON
    assert_equal "1", response.headers["X-Per-Page"]
  end

  test "page vượt quá trang cuối trả mảng rỗng, vẫn 200" do
    get products_url, params: { page: 99 }, headers: ACCEPT_JSON

    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "page và per_page rác không gây 500" do
    get products_url, params: { page: "abc", per_page: [ 1, 2 ] }, headers: ACCEPT_JSON
    assert_response :success

    get products_url, params: { page: { x: 1 } }, headers: ACCEPT_JSON
    assert_response :success
  end

  test "Link header dùng đường dẫn tương đối, không lấy từ Host" do
    get products_url, params: { per_page: 2 }, headers: ACCEPT_JSON.merge("Host" => "evil.example")

    assert_not_includes response.headers["Link"], "evil.example"
  end

  # --- sắp xếp ---

  test "sort tăng dần và giảm dần" do
    get products_url, params: { sort: "price" }, headers: ACCEPT_JSON
    assert_equal [ 100_000, 150_000, 200_000, 500_000, 700_000 ], response.parsed_body.map { |p| p["price"].to_i }

    get products_url, params: { sort: "-price" }, headers: ACCEPT_JSON
    assert_equal [ 700_000, 500_000, 200_000, 150_000, 100_000 ], response.parsed_body.map { |p| p["price"].to_i }
  end

  test "sort nhiều trường" do
    get products_url, params: { sort: "category,-price" }, headers: ACCEPT_JSON

    assert_equal [ "Cáp USB-C 1m", "Ốp chống sốc 14", "Ốp trong suốt 13", "Sạc không dây", "Sạc nhanh 20W" ], names
  end

  test "sort trường không được phép trả 400" do
    get products_url, params: { sort: "id; DROP TABLE products" }, headers: ACCEPT_JSON

    assert_response :bad_request
    assert_equal 5, Product.count
  end

  test "không có sort thì thứ tự ổn định theo id" do
    get products_url, headers: ACCEPT_JSON

    assert_equal Product.order(:id).pluck(:name), names
  end

  # --- lọc ---

  test "lọc theo category" do
    get products_url, params: { category: "case" }, headers: ACCEPT_JSON

    assert_equal 2, response.parsed_body.size
    assert_equal "2", response.headers["X-Total-Count"]
  end

  test "lọc category không phân biệt hoa thường và khoảng trắng" do
    get products_url, params: { category: "  CASE " }, headers: ACCEPT_JSON

    assert_equal 2, response.parsed_body.size
  end

  test "lọc theo khoảng giá" do
    get products_url, params: { min_price: 150_000, max_price: 500_000, sort: "price" }, headers: ACCEPT_JSON

    assert_equal [ "Cáp USB-C 1m", "Ốp chống sốc 14", "Sạc nhanh 20W" ], names
  end

  test "kết hợp lọc, sắp xếp, phân trang" do
    get products_url, params: { category: "charger", sort: "-price", per_page: 1 }, headers: ACCEPT_JSON

    assert_equal [ "Sạc không dây" ], names
    assert_equal "2", response.headers["X-Total-Count"]
  end

  test "min_price và max_price không phải số trả 400" do
    [ "abc", "NaN", "Infinity" ].each do |bad|
      get products_url, params: { min_price: bad }, headers: ACCEPT_JSON
      assert_response :bad_request, "min_price=#{bad} phải trả 400"

      get products_url, params: { max_price: bad }, headers: ACCEPT_JSON
      assert_response :bad_request, "max_price=#{bad} phải trả 400"
    end
  end

  test "tham số dạng mảng hay hash không gây 500" do
    get products_url, params: { category: { a: 1 } }, headers: ACCEPT_JSON
    assert_response :success

    get products_url, params: { min_price: [ 1, 2 ] }, headers: ACCEPT_JSON
    assert_response :bad_request
  end
end
