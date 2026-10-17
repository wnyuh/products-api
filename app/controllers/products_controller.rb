class ProductsController < ApplicationController
  include Paginatable
  include Authenticatable

  SORTABLE_FIELDS = %w[ name price category created_at ].freeze

  before_action :set_product, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ export ] # export cần đăng nhập, index thì không

  # GET /products?category=&min_price=&max_price=&sort=-price,name&page=&per_page=
  def index
    # Khởi tạo query gốc: Tải trước (preload) ảnh và danh mục để chặn lỗi N+1 query
    scope = Product.with_attached_image.includes(:category)

    # lọc qua ProductFilter, sau đó sort và phân trang
    @products = paginate(sorted(product_filter.call(scope)))

    # Trả về kết quả JSON cho frontend
    render json: @products
  end

  # GET /products/export?category=&min_price=&max_price=&q=
  # Áp dụng cùng bộ lọc với index, nhưng không sort và không phân trang
  def export
    scope = product_filter.call

    send_data ProductCsvExporter.new(scope).call,
              filename: "products-#{Date.current}.csv", # tên file có ngày, ví dụ products-2026-10-13.csv
              type: "text/csv; charset=utf-8"           # MIME type để trình duyệt hiểu đây là CSV
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy!
  end

  private

  # Đọc params một lần ở controller rồi truyền vào ProductFilter
  def product_filter
    ProductFilter.new(
      q: params[:q],
      category: params[:category],
      min_price: params[:min_price],
      max_price: params[:max_price]
    )
  end

  # sort=-price,name: dấu "-" là giảm dần. Luôn thêm id để thứ tự ổn định khi phân trang.
  def sorted(scope)
    order = params[:sort].to_s.split(",").map do |field|
      name = field.delete_prefix("-")
      raise ActionController::BadRequest, "sort: '#{name}' is not sortable" unless SORTABLE_FIELDS.include?(name)

      direction = field.start_with?("-") ? :desc : :asc
      name == "category" ? Category.arel_table[:slug].public_send(direction) : { name => direction }
    end

    scope = scope.joins(:category) if order.any? { |o| o.is_a?(Arel::Nodes::Ordering) }
    scope.order(*order, :id)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.expect(product: [ :name, :price, :category_id, :description ])
  end
end
