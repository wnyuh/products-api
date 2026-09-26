class ProductsController < ApplicationController
  include Paginatable

  SORTABLE_FIELDS = %w[ name price category created_at ].freeze

  before_action :set_product, only: %i[ show update destroy ]

  # GET /products?category=&min_price=&max_price=&sort=-price,name&page=&per_page=
  def index
    @products = paginate(sorted(filtered(Product.all)))

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
  # Dùng lại chuẩn hóa của model để ?category=%20CASE khớp với "case" đã lưu
  def filtered(scope)
    scope = scope.where(category: Product.normalize_value_for(:category, params[:category].to_s)) if params[:category].present?
    scope = scope.where(price: decimal_param(:min_price)..) if params[:min_price].present?
    scope = scope.where(price: ..decimal_param(:max_price)) if params[:max_price].present?
    scope
  end

  # sort=-price,name: dấu "-" là giảm dần. Luôn thêm id để thứ tự ổn định khi phân trang.
  def sorted(scope)
    order = params[:sort].to_s.split(",").map do |field|
      name = field.delete_prefix("-")
      raise ActionController::BadRequest, "sort: '#{name}' is not sortable" unless SORTABLE_FIELDS.include?(name)

      { name => field.start_with?("-") ? :desc : :asc }
    end

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
    params.expect(product: [ :name, :price, :category, :description ])
  end
end
