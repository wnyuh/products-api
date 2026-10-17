require "csv"

# Biến một tập Product thành chuỗi CSV.
# Không biết gì về HTTP hay Job, nên dùng lại được ở controller (Phase 1) lẫn job (Phase 2).
class ProductCsvExporter
  HEADERS = %w[id name category price description created_at].freeze

  # BOM giúp Excel nhận ra file UTF-8. Thiếu BOM thì tiếng Việt bị vỡ.
  BOM = "\uFEFF".freeze

  # Ô bắt đầu bằng các ký tự này sẽ bị Excel hiểu là công thức
  FORMULA_PREFIX = /\A[=+\-@\t\r]/

  def initialize(scope = Product.all)
    @scope = scope
  end

  def call
    body = CSV.generate do |csv|
      csv << HEADERS
      # find_each: đọc theo lô 1000 dòng, không nạp cả bảng vào RAM
      # includes(:category): nạp category một lần, tránh N+1
      @scope.includes(:category).find_each do |product|
        csv << row_for(product)
      end
    end

    BOM + body
  end

  private

  def row_for(product)
    [
      product.id,
      safe(product.name),
      product.category_slug,
      product.price.to_s("F"), # "350000.0" thay vì "0.35e6"
      safe(product.description),
      product.created_at.iso8601
    ]
  end

  # Thêm dấu ' trước ô nguy hiểm để Excel coi nó là chữ, không chạy như công thức
  def safe(value)
    value.to_s.match?(FORMULA_PREFIX) ? "'#{value}" : value
  end
end
