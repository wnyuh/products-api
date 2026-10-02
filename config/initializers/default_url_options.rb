# Host tuyệt đối cho URL ảnh ActiveStorage trong JSON (Product#image_url) — model không có request để lấy host.
# Đổi bằng APP_HOST khi Rails không chạy ở 127.0.0.1:3000.
Rails.application.routes.default_url_options[:host] = ENV.fetch("APP_HOST", "127.0.0.1:3000")
