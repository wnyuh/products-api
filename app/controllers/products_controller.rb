class ProductsController < ApplicationController
  include Paginatable

  SORTABLE_FIELDS = %w[ name price category created_at ].freeze

  before_action :set_product, only: %i[ show update destroy ]

  # GET /products?category=&min_price=&max_price=&sort=-price,name&page=&per_page=
  def index
    # sửa lỗi N + 1 bằng includes
    @products = paginate(sorted(filtered(Product.with_attached_image.includes(:category))))

    render json: @products
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
  # Dùng lại chuẩn hóa của Category để ?category=%20CASE khớp với slug "case" đã lưu
  def filtered(scope)
    if params[:category].present?
      slug = Category.normalize_value_for(:slug, params[:category].to_s)
      scope = scope.joins(:category).where(categories: { slug: slug })
    end
    scope = scope.where(price: decimal_param(:min_price)..) if params[:min_price].present?
    scope = scope.where(price: ..decimal_param(:max_price)) if params[:max_price].present?
    scope
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

  def decimal_param(key)
    value = BigDecimal(params[key].to_s, exception: false)
    raise ActionController::BadRequest, "#{key} must be a finite number" unless value&.finite?

    value
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
