require "test_helper"
class CategoryTest < ActiveSupport::TestCase
  def valid_attrs
    { name: "Máy tính bảng", slug: "tablet" }
  end

  test "hợp lệ với dữ liệu đầy đủ" do
    assert Category.new(valid_attrs).valid?
  end

  test "name bắt buộc, tối đa 50 ký tự, không trùng (không phân biệt hoa thường)" do
    [ nil, "", "   ", "A" * 51, "cáp sạc" ].each do |bad|
      assert_not Category.new(valid_attrs.merge(name: bad)).valid?, "name=#{bad.inspect} phải bị từ chối"
    end
  end

  test "slug bắt buộc, chữ thường/số/gạch dưới, bắt đầu bằng chữ, tối đa 30 ký tự, không trùng" do
    [ nil, "", "   ", "9tab", "a b", "a-b", "ốp", "a" * 31, "case" ].each do |bad|
      assert_not Category.new(valid_attrs.merge(slug: bad)).valid?, "slug=#{bad.inspect} phải bị từ chối"
    end
  end

  test "slug được chuẩn hóa về chữ thường, bỏ khoảng trắng đầu cuối" do
    assert_equal "tablet", Category.new(valid_attrs.merge(slug: "  TABLET ")).slug
  end

  test "không xoá được category còn sản phẩm" do
    category = categories(:case)

    assert_no_difference("Category.count") { category.destroy }
    assert_includes category.errors.full_messages.join, "dependent products exist"
  end
end
