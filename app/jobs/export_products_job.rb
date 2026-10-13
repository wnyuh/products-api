
# Xuất CSV sản phẩm ở nền. Chỉ nhận id để luôn đọc dữ liệu mới nhất khi chạy
class ExportProductsJob < ApplicationJob
  # Đưa vào queue "exports" để export nặng không chặn các job khác
  queue_as :exports

  # Record đã bị xoá thì retry cũng vô ích, bỏ job luôn
  discard_on ActiveRecord::RecordNotFound

  def perform(product_export_id)
    export = ProductExport.find(product_export_id)

    # Idempotent: đã xong thì thoát, không ghi đè file và không đưa trạng thái lùi lại
    return if export.done?

    export.start!

    # filters được lưu dạng JSON (key là chuỗi), đổi sang symbol để truyền làm keyword
    scope = ProductFilter.new(**export.filters.to_h.symbolize_keys).call
    csv = ProductCsvExporter.new(scope).call

    export.file.attach(io: StringIO.new(csv), filename: "products-#{export.id}.csv", content_type: "text/csv")
    export.complete!
  rescue StandardError => e
    # export có thể là nil nếu find đã lỗi, nên dùng &.
    export&.mark_failed!(e.message)
    # Báo lại để Sidekiq retry. Không return vì sẽ coi job là thành công và không bao giờ thử lại
    raise
  end
end
