require "test_helper"

# Kiểm tra vòng đời và quan hệ của ProductExport
class ProductExportTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Tester", email: "export@example.com", password: "secret1", confirmed: true)
  end

  test "mặc định là pending" do
    assert ProductExport.new(user: @user).pending?
  end

  test "phải thuộc về một user" do
    assert_not ProductExport.new.valid?
  end

  test "status không hợp lệ bị từ chối" do
    assert_raises(ArgumentError) { ProductExport.new(user: @user).status = "lung_tung" }
  end

  test "đi đúng vòng đời pending → processing → done" do
    export = ProductExport.create!(user: @user)

    export.start!
    assert export.processing?

    export.complete!
    assert export.done?
    assert export.completed_at.present?
  end

  test "mark_failed! lưu lý do lỗi và chuyển sang failed" do
    export = ProductExport.create!(user: @user)

    export.mark_failed!("boom")

    assert export.failed?
    assert_equal "boom", export.error_message
  end

  test "giữ được file đính kèm" do
    export = ProductExport.create!(user: @user)
    export.file.attach(io: StringIO.new("id,name\n"), filename: "products.csv", content_type: "text/csv")

    assert export.file.attached?
  end
end
