require "test_helper"

# Kiểm tra ExportProductsJob: thành công, lọc, idempotent, lỗi và record đã bị xoá
class ExportProductsJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(name: "Tester", email: "job@example.com", password: "secret1", confirmed: true)
  end

  test "tạo file CSV và chuyển sang done" do
    export = ProductExport.create!(user: @user)

    ExportProductsJob.perform_now(export.id)

    export.reload
    assert export.done?
    assert export.file.attached?
    assert_includes export.file.download, "id,name"
  end

  test "áp dụng bộ lọc đã lưu" do
    export = ProductExport.create!(user: @user, filters: { category: "case" })

    ExportProductsJob.perform_now(export.id)

    csv = export.reload.file.download.force_encoding(Encoding::UTF_8)
    assert_includes csv, "Clear Case"
    refute_includes csv, "Sạc"
  end

  test "chạy lại khi đã done thì không ghi đè file" do
    export = ProductExport.create!(user: @user)
    ExportProductsJob.perform_now(export.id)
    blob_id = export.reload.file.blob.id

    ExportProductsJob.perform_now(export.id)

    assert_equal blob_id, export.reload.file.blob.id
    assert export.done?
  end

  test "lỗi thì đánh dấu failed, lưu lý do và báo lại để retry" do
    export = ProductExport.create!(user: @user, filters: { min_price: "abc" })

    assert_raises(ProductFilter::InvalidParam) { ExportProductsJob.perform_now(export.id) }

    export.reload
    assert export.failed?
    assert_equal "min_price phải là số hữu hạn", export.error_message
  end

  test "record đã bị xoá thì bỏ qua, không lỗi" do
    assert_nothing_raised { ExportProductsJob.perform_now(0) }
  end
end
