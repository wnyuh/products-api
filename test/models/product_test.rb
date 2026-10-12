require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def valid_attrs
    { name: "Ốp lưng iPhone 15 Pro", price: 350_000, category: categories(:case), description: "Ốp trong suốt" }
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

  test "category bắt buộc và phải tồn tại" do
    assert_not Product.new(valid_attrs.merge(category: nil)).valid?
    assert_not Product.new(valid_attrs.merge(category: nil, category_id: 0)).valid?
  end

  test "product thuộc về đúng category" do
    assert_equal categories(:case), Product.new(valid_attrs).category
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

  test "DB từ chối name, price, category_id NULL dù bỏ qua validation" do
    %i[ name price category_id ].each do |column|
      assert_raises(ActiveRecord::NotNullViolation, "#{column} NULL phải bị DB từ chối") do
        Product.new(valid_attrs.merge(column => nil)).save!(validate: false)
      end
    end
  end

  test "image_url là nil khi chưa có ảnh" do
    assert_nil Product.create!(valid_attrs).image_url
  end

  test "image_url là URL tuyệt đối tới ảnh đã attach và có trong JSON" do
    product = Product.create!(valid_attrs)
    product.image.attach(io: StringIO.new("fake-jpeg"), filename: "op-lung.jpg", content_type: "image/jpeg")

    assert_match %r{\Ahttp://[^/]+/rails/active_storage/blobs/proxy/.+/op-lung\.jpg\z}, product.image_url
    assert_equal product.image_url, product.as_json["image_url"]
  end
end
