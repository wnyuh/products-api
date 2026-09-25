require "test_helper"

class IphoneTest < ActiveSupport::TestCase
  def valid_attrs
    { name: "iphone 15 Pro", storage: 256, price: 27_990_000, color: "Black Titanium" }
  end

  test "hợp lệ với dữ liệu đầy đủ" do
    assert Iphone.new(valid_attrs).valid?
  end

  test "color là tùy chọn" do
    assert Iphone.new(valid_attrs.merge(color: nil)).valid?
  end

  test "name bắt buộc và tối đa 100 ký tự" do
    assert_not Iphone.new(valid_attrs.merge(name: nil)).valid?
    assert_not Iphone.new(valid_attrs.merge(name: "")).valid?
    assert_not Iphone.new(valid_attrs.merge(name: "A" * 101)).valid?
  end

  test "color tối đa 50 ký tự" do
    assert_not Iphone.new(valid_attrs.merge(color: "A" * 51)).valid?
  end

  test "storage phải là số nguyên dương trong giới hạn" do
    [ nil, 0, -1, 1.5, "256GB", "abc", 4097, 10**30 ].each do |bad|
      assert_not Iphone.new(valid_attrs.merge(storage: bad)).valid?, "storage=#{bad.inspect} phải bị từ chối"
    end
  end

  test "price phải là số không âm trong giới hạn" do
    [ nil, -5, "abc", "NaN", "Infinity", 10**10 ].each do |bad|
      assert_not Iphone.new(valid_attrs.merge(price: bad)).valid?, "price=#{bad.inspect} phải bị từ chối"
    end
  end

  test "price 0 và giá trị lớn hợp lệ nằm trong giới hạn" do
    assert Iphone.new(valid_attrs.merge(price: 0)).valid?
    assert Iphone.new(valid_attrs.merge(price: "9999999999.99")).valid?
  end
end
