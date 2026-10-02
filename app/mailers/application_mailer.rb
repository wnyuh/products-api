class ApplicationMailer < ActionMailer::Base
  # Địa chỉ email người gửi mặc định cho toàn bộ thư trong hệ thống
  default from: "no-reply@iphone-shop.local"
  layout "mailer"
end
