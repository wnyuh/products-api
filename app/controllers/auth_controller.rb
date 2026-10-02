class AuthController < ApplicationController
  include Authenticatable

  # Chỉ áp dụng kiểm tra vé đối với hành động me (register, login, confirm ai cũng vào được)
  before_action :authenticate_user!, only: [ :me, :logout ]
  # POST /auth/register
  def register
    user = User.new(register_params)

    if user.save
      UserMailer.with(user: user).confirmation.deliver_later
      render json: user_json(user), status: :created
    else
      render json: user.errors, status: :unprocessable_content
    end
  end

  # GET /auth/confirm?token=...
  def confirm
    token = params[:token]
    user = User.find_by(confirmation_token: token) if token.present?

    # 1. Nếu không tìm thấy ai sở hữu token này -> báo lỗi 404
    return render json: { error: "Mã xác nhận không hợp lệ hoặc không tồn tại" }, status: :not_found unless user

    # 2. Tính chất Idempotent: Nếu đã kích hoạt rồi thì vẫn trả về thành công (không báo lỗi)
    if user.confirmed?
      return render json: { message: "Tài khoản đã được xác nhận trước đó" }, status: :ok
    end

    # 3. Kiểm tra liên kết có bị quá hạn 24 giờ hay không
    if user.confirmation_sent_at.blank? || user.confirmation_sent_at < 24.hours.ago
      return render json: { error: "Liên kết xác nhận đã hết hạn (chỉ có hiệu lực trong 24 giờ)" }, status: :gone
    end

    # 4. Kích hoạt tài khoản thành công!
    user.update!(confirmed: true)
    render json: { message: "Xác nhận tài khoản thành công" }, status: :ok
  end

  # POST /auth/login
  def login
    # 1. Xác thực email và mật khẩu (Rails 7.1+ hỗ trợ authenticate_by chống tấn công timing attack)
    user = User.authenticate_by(email: login_params[:email], password: login_params[:password])

    # Nếu sai email hoặc sai mật khẩu: báo lỗi chung chung 401
    unless user
      return render json: { error: "Email hoặc mật khẩu không chính xác" }, status: :unauthorized
    end

    # 2. Nếu mật khẩu đúng nhưng CHƯA xác nhận email: chặn lại với mã 403 Forbidden
    unless user.confirmed?
      return render json: { error: "Tài khoản chưa được xác nhận. Vui lòng kiểm tra email của bạn." }, status: :forbidden
    end

    # 3. Mọi thứ hợp lệ: In vé JWT (chứa id của user) và trao cho khách hàng
    token = JsonWebToken.encode(sub: user.id)
    render json: { token: token, user: user_json(user) }, status: :ok
  end

  # GET /auth/me
  def me
    render json: user_json(@current_user), status: :ok
  end

  # POST /auth/logout
  def logout
    # Ghi mã sê-ri jti của vé hiện tại vào sổ đen
    DenylistedToken.create!(
      jti: @current_payload[:jti],
      exp: Time.at(@current_payload[:exp])
    )

    render json: { message: "Đăng xuất thành công" }, status: :ok
  end

  private
  def register_params
    params.expect(user: [ :name, :email, :password ])
  end

  def user_json(user)
    user.slice(:id, :name, :email, :confirmed)
  end

  def login_params
    params.expect(user: [ :email, :password ])
  end
end
