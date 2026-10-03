module Authenticatable
  extend ActiveSupport::Concern

  included do
    # Giúp các view hoặc controller con có thể gọi current_user
    attr_reader :current_user
  end

  # Bắt buộc phải đăng nhập mới được đi tiếp, nếu không có vé hợp lệ thì chặn lại (401)
  def authenticate_user!
    token = extract_token_from_header
    payload = JsonWebToken.decode(token) if token.present?

    # 1. Nếu vé nằm trong sổ đen (đã từng bấm đăng xuất) -> từ chối ngay lập tức
    if payload && DenylistedToken.exists?(jti: payload[:jti])
      return render json: { error: "Phiên đăng nhập đã kết thúc. Vui lòng đăng nhập lại." }, status: :unauthorized
    end

    # 2. Kiểm tra vé hợp lệ và tìm người dùng sở hữu vé
    if payload && (@current_user = User.find_by(id: payload[:sub]))
      @current_payload = payload # Lưu lại payload để hàm logout lấy được mã jti
    else
      render json: { error: "Yêu cầu đăng nhập để thực hiện hành động này" }, status: :unauthorized
    end
  end

  private

  # Tiêu chuẩn quốc tế: Token gửi trong header có dạng "Bearer <chuỗi_token>"
  def extract_token_from_header
    header = request.headers["Authorization"]
    header&.split(" ")&.last if header&.start_with?("Bearer ")
  end
end
