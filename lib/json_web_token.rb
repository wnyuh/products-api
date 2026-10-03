class JsonWebToken
  # Lấy chìa khóa bí mật của ứng dụng Rails để ký tên vào vé
  SECRET_KEY = Rails.application.secret_key_base

  # 1. Hàm in vé (Đóng gói thông tin + Ký tên niêm phong)
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i                   # Hạn sử dụng: 24 giờ kể từ bây giờ
    payload[:jti] = SecureRandom.uuid          # Mã sê-ri độc nhất của riêng chiếc vé này
    JWT.encode(payload, SECRET_KEY, "HS256")   # Ký bằng thuật toán chuẩn bảo mật HS256
  end

  # 2. Hàm soi vé (Giải mã và kiểm tra con dấu niêm phong)
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature, JWT::DecodeError
    nil # Nếu vé hết hạn hoặc bị sửa đổi giả mạo -> trả về nil (không hợp lệ)
  end
end
