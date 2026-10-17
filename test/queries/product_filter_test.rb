require "test_helper"

# Kiểm tra logic lọc độc lập với controller
class ProductFilterTest < ActiveSupport::TestCase
  test "lọc theo category slug" do
    assert_equal [ products(:one) ], ProductFilter.new(category: "case").call.to_a
  end

  test "lọc theo khoảng giá" do
    assert_equal [ products(:one) ], ProductFilter.new(max_price: 400_000).call.to_a
  end

  test "tìm theo q không phân biệt dấu" do
    products(:two).save! # fixture không chạy before_save nên name_search còn NULL
    assert_equal [ products(:two) ], ProductFilter.new(q: "Sạc").call.to_a
  end

  test "giá không phải số thì báo InvalidParam" do
    assert_raises(ProductFilter::InvalidParam) { ProductFilter.new(min_price: "abc").call }
  end
end
