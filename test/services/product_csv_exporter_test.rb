require "test_helper"
require "csv"

class ProductCsvExporterTest < ActiveSupport::TestCase
  # Bỏ BOM rồi parse lại, giống cách người dùng mở file
  def parse(csv_string)
    CSV.parse(csv_string.delete_prefix(ProductCsvExporter::BOM), headers: true)
  end

  test "dòng đầu là header đúng thứ tự" do
    assert_equal ProductCsvExporter::HEADERS, parse(ProductCsvExporter.new.call).headers
  end

  test "mỗi sản phẩm đúng một dòng" do
    assert_equal Product.count, parse(ProductCsvExporter.new.call).size
  end

  test "ghi category bằng slug và giá đúng giá trị" do
    product = products(:one)
    row = parse(ProductCsvExporter.new.call).find { |r| r["id"] == product.id.to_s }

    assert_equal "case", row["category"]
    assert_equal BigDecimal("350000"), BigDecimal(row["price"])
  end

  test "escape đúng dấu phẩy và ngoặc kép (round-trip)" do
    name = 'Ốp "xịn", loại 1'
    product = Product.create!(name: name, price: 1, category: categories(:case))

    row = parse(ProductCsvExporter.new.call).find { |r| r["id"] == product.id.to_s }
    assert_equal name, row["name"]
  end

  test "chống CSV injection: ô bắt đầu bằng = bị vô hiệu hóa" do
    product = Product.create!(name: "=HYPERLINK(\"http://x\")", price: 1, category: categories(:case))

    row = parse(ProductCsvExporter.new.call).find { |r| r["id"] == product.id.to_s }
    assert_equal "'=HYPERLINK(\"http://x\")", row["name"]
  end

  test "file bắt đầu bằng BOM để Excel đọc đúng tiếng Việt" do
    assert ProductCsvExporter.new.call.start_with?("\uFEFF")
  end
end
