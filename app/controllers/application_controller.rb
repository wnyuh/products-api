class ApplicationController < ActionController::API
  # Lỗi tham số lọc trả 400 thay vì 500, dùng chung cho mọi controller
  rescue_from ProductFilter::InvalidParam do |error|
    render json: { error: error.message }, status: :bad_request
  end
end
