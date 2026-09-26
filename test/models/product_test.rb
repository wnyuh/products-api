require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def valid_attrs
    { name: "Ốp lưng iPhone 15 Pro", price: 350_000, category: "case", description: "Ốp trong suốt" }
  end

  test "hợp lệ với dữ liệu đầy đủ" do
    assert Product.new(valid_attrs).valid?
  end

  test "description là tùy chọn và tối đa 500 ký tự" do
    assert Product.new(valid_attrs.merge(description: nil)).valid?
    assert Product.new(valid_attrs.merge(description: "A" * 500)).valid?
    assert_not Product.new(valid_attrs.merge(description: "A" * 501)).valid?
  end

  test "name bắt buộc và tối đa 100 ký tự" do
    [ nil, "", "   ", "A" * 101 ].each do |bad|
      assert_not Product.new(valid_attrs.merge(name: bad)).valid?, "name=#{bad.inspect} phải bị từ chối"
    end
  end

  test "category bắt buộc, chữ thường/số/gạch dưới, bắt đầu bằng chữ, tối đa 30 ký tự" do
    [ nil, "", "   ", "9case", "a b", "a-b", "ốp", "a" * 31 ].each do |bad|
      assert_not Product.new(valid_attrs.merge(category: bad)).valid?, "category=#{bad.inspect} phải bị từ chối"
    end
    %w[ case charger screen_protector usb_c2 ].each do |good|
      assert Product.new(valid_attrs.merge(category: good)).valid?, "category=#{good.inspect} phải hợp lệ"
    end
  end

  test "category được chuẩn hóa về chữ thường, bỏ khoảng trắng thừa" do
    product = Product.new(valid_attrs.merge(category: "  Case "))

    assert_equal "case", product.category
    assert product.valid?
  end

  test "name được bỏ khoảng trắng đầu cuối" do
    assert_equal "Sạc 20W", Product.new(valid_attrs.merge(name: "  Sạc 20W  ")).name
  end

  test "price phải là số không âm trong giới hạn" do
    [ nil, -5, "abc", "NaN", "Infinity", 10**10 ].each do |bad|
      assert_not Product.new(valid_attrs.merge(price: bad)).valid?, "price=#{bad.inspect} phải bị từ chối"
    end
    assert Product.new(valid_attrs.merge(price: 0)).valid?
    assert Product.new(valid_attrs.merge(price: "9999999999.99")).valid?
  end

  test "DB từ chối name, price, category NULL dù bỏ qua validation" do
    %i[ name price category ].each do |column|
      assert_raises(ActiveRecord::NotNullViolation, "#{column} NULL phải bị DB từ chối") do
        Product.new(valid_attrs.merge(column => nil)).save!(validate: false)
      end
    end
  end
end
