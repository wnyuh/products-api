# Logic lọc sản phẩm dùng chung cho index, export và job.
# Không đọc params, nên gọi được từ bất kỳ đâu (kể cả background job).
class ProductFilter
  # Lỗi khi tham số lọc không hợp lệ, controller sẽ đổi thành 400
  class InvalidParam < StandardError; end

  def initialize(q: nil, category: nil, min_price: nil, max_price: nil)
    @q = q
    @category = category
    @min_price = min_price
    @max_price = max_price
  end

  # scope mặc định là toàn bộ sản phẩm; index có thể truyền scope đã preload
  def call(scope = Product.all)
    scope = scope.ransack(name_search_cont: Product.fold(@q)).result

    if @category.present?
      # Dùng chuẩn hoá của Category để "%20CASE" khớp với slug "case"
      slug = Category.normalize_value_for(:slug, @category.to_s)
      scope = scope.joins(:category).where(categories: { slug: slug })
    end

    scope = scope.where(price: decimal(:min_price, @min_price)..) if @min_price.present?
    scope = scope.where(price: ..decimal(:max_price, @max_price)) if @max_price.present?
    scope
  end

  private

  def decimal(key, value)
    number = BigDecimal(value.to_s, exception: false)
    raise InvalidParam, "#{key} phải là số hữu hạn" unless number&.finite?

    number
  end
end
