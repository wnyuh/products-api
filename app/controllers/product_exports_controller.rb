# API export bất đồng bộ: tạo yêu cầu (202), theo dõi trạng thái và tải file
class ProductExportsController < ApplicationController
  include Authenticatable

  before_action :authenticate_user!

  # Lỗi tham số lọc trả 400 ngay tại request, không tạo bản ghi
  rescue_from ProductFilter::InvalidParam do |error|
    render json: { error: error.message }, status: :bad_request
  end

  # POST /product_exports
  def create
    filters = filter_params.to_h.symbolize_keys

    # Kiểm tra bộ lọc trước khi tạo bản ghi. call chỉ dựng câu lệnh, không chạy query
    ProductFilter.new(**filters).call

    export = current_user.product_exports.create!(filters: filters)
    ExportProductsJob.perform_later(export.id)

    render json: export_json(export), status: :accepted, location: product_export_url(export)
  end

  # GET /product_exports/1
  def show
    # Tìm trong phạm vi của user hiện tại: export của người khác trả 404
    export = current_user.product_exports.find(params.expect(:id))

    render json: export_json(export)
  end

  private

  def filter_params
    params.permit(:q, :category, :min_price, :max_price)
  end

  def export_json(export)
    {
      id: export.id,
      status: export.status,
      error_message: export.error_message,
      # Chỉ trả link tải khi file đã sẵn sàng
      download_url: (download_url_for(export) if export.done? && export.file.attached?)
    }
  end

  # Link tải file qua Active Storage, đã có chữ ký nên không cần đăng nhập để tải
  def download_url_for(export)
    Rails.application.routes.url_helpers.rails_blob_path(export.file, disposition: "attachment", only_path: true)
  end
end
