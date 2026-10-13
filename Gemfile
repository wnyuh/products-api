source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# json 3.x chỉ nhận keyword args, ActiveSupport 8.1.x còn gọi JSON.parse(src, opts)
# với hash vị trí nên mọi request JSON đều 400. Gỡ ràng buộc khi Rails hỗ trợ json 3.
gem "json", "< 3"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# bcrypt: Mã hóa một chiều (băm) mật khẩu, tuyệt đối không lưu mật khẩu thô vào DB
gem "bcrypt", "~> 3.1.7"

# jwt: Tạo và kiểm tra "vé vào cổng" điện tử (JSON Web Token) có hạn dùng cho phiên đăng nhập
gem "jwt"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "bullet"
end

group :development do
  # Tự động mở email trên trình duyệt web ở máy cá nhân khi gửi mail
  gem "letter_opener"
end

gem "rswag"

gem "pagy", "~> 43.6"

gem "ransack"

gem "csv"

gem "sidekiq", "~> 8.1"
