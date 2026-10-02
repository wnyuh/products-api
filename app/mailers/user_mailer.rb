class UserMailer < ApplicationMailer
  # Soạn thư gửi liên kết xác nhận tài khoản
  def confirmation
    @user = params[:user]
    frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:3001")
    @confirmation_url = "#{frontend_url}/confirm?token=#{@user.confirmation_token}"

    mail(to: @user.email, subject: "Xác nhận tài khoản iPhone Shop")
  end
end
