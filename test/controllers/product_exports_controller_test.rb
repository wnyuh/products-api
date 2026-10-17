require "test_helper"

# Kiểm thử API export bất đồng bộ: tạo (202), theo dõi, và phân quyền
class ProductExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Owner", email: "owner@example.com", password: "secret1", confirmed: true)
    @other = User.create!(name: "Other", email: "other@example.com", password: "secret1", confirmed: true)
    @auth = { "Authorization" => "Bearer #{JsonWebToken.encode(sub: @user.id)}" }
  end

  test "không có token trả 401" do
    post product_exports_url, params: { category: "iphone" }
    assert_response :unauthorized
  end

  test "tạo export trả 202 và xếp job" do
    assert_enqueued_with(job: ExportProductsJob) do
      post product_exports_url, params: { category: "iphone" }, headers: @auth
    end

    assert_response :accepted
    body = response.parsed_body
    assert_equal "pending", body["status"]
    assert_nil body["download_url"]
  end

  test "bộ lọc sai trả 400 và không tạo bản ghi" do
    assert_no_difference "ProductExport.count" do
      post product_exports_url, params: { min_price: "abc" }, headers: @auth
    end

    assert_response :bad_request
  end

  test "xem trạng thái của chính mình" do
    export = ProductExport.create!(user: @user)

    get product_export_url(export), headers: @auth

    assert_response :ok
    assert_equal "pending", response.parsed_body["status"]
  end

  test "khi done thì có download_url" do
    export = ProductExport.create!(user: @user)
    ExportProductsJob.perform_now(export.id)

    get product_export_url(export), headers: @auth

    assert_equal "done", response.parsed_body["status"]
    assert_match %r{/rails/active_storage/}, response.parsed_body["download_url"]
  end

  test "không xem được export của người khác: trả 404" do
    export = ProductExport.create!(user: @other)

    get product_export_url(export), headers: @auth

    assert_response :not_found
  end
end
