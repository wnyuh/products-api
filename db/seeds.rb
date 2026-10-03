# db/seeds.rb
# ==============================================================================
# SEED DATA: APPLE STORE PRODUCTS WITH OFFICIAL IMAGES
# ==============================================================================
require "open-uri"
require "cgi"

puts "🚀 Bắt đầu cập nhật dữ liệu và hình ảnh sản phẩm (Seed database)..."

has_category_model  = defined?(Category) && Category.respond_to?(:find_or_create_by!)
has_category_id_col = Product.column_names.include?("category_id")
has_category_col    = Product.column_names.include?("category")
has_image_url_col   = Product.column_names.include?("image_url")

# Chuẩn hoá slug danh mục theo validation /\A[a-z][a-z0-9_]*\z/
CATEGORY_SLUGS = {
  "Mac"         => "mac",
  "iPhone"      => "iphone",
  "iPad"        => "ipad",
  "Apple Watch" => "apple_watch",
  "AirPods"     => "airpods",
  "TV & Nhà"    => "tv_home",
  "Phụ kiện"    => "accessories"
}.freeze

# Hàm hỗ trợ tải và đính kèm ảnh qua ActiveStorage
def attach_image(product, source)
  return if source.blank?
  return if product.image.attached?

  print "    📥 Đang tải ảnh cho #{product.name}... "
  io = URI.parse(source).open(
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    open_timeout: 10,
    read_timeout: 25
  )
  content_type = io.content_type || "image/jpeg"
  ext = case content_type
        when "image/png"  then "png"
        when "image/webp" then "webp"
        else "jpg"
        end

  product.image.attach(
    io: io,
    filename: "#{product.name.parameterize}.#{ext}",
    content_type: content_type
  )
  puts "✅ Xong"
rescue StandardError => e
  puts "⚠️ Bỏ qua (Lỗi mạng: #{e.message})"
end

# 1. Bảng dữ liệu sản phẩm đầy đủ kèm ảnh chính hãng Apple Store
catalog_data = {
  "Mac" => [
    {
      name: "MacBook Neo",
      price: 19_499_000,
      description: "Concept laptop mỏng nhẹ đột phá, đem trải nghiệm Apple silicon thế hệ mới đến gần hơn với mọi người dùng.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/macbook-neo-digitalmat-gallery-2-202603?wid=728&hei=666&fmt=jpeg&qlt=90&.v=NC96emhJemczTlpnY1kzRXYvV1dEVHBhZEVDYXdNalJLdkllSGFmNnBVVDJ1Zk55MjBoaG1LbldpV1JIK0hPYW5QZzJFYTM2YWJROS9meXA5Z09BMUtMalVvbmRiUjhIaGRVMlJ3Y1BOc05pRkpBNEp1SjJ3TUlYM3lGVEFJZ2M"
    },
    {
      name: "MacBook Air",
      price: 35_999_000,
      description: "Thiết kế siêu mỏng nhẹ, pin cả ngày dài cùng hiệu năng vượt trội từ chip Apple silicon M-series.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/macbook-air-13-digitalmat-gallery-1-202503?wid=728&hei=666&fmt=png-alpha&.v=RWZDcE1Pa2MvREpxR2hwendCZFpRa2EvQmI5ZjZseVhPSEJZVkYxZ09JdFpUdXE4MkhYYjRLTVptRHE3NGNZdHhaVXN2UmVLZWxyY01GTDZmcDYxbitZbnd2dEloRUI0QkxmQVJESllzWlN5ekw2b3VPdnZLWU14ZXc2aDkvRXI"
    },
    {
      name: "MacBook Pro",
      price: 54_999_000,
      description: "Hiệu năng đồ họa đỉnh cao với màn hình Liquid Retina XDR và chip M-series Pro/Max chuyên nghiệp.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/mbp-14-digitalmat-gallery-1-202410?wid=728&hei=666&fmt=png-alpha&.v=dmVFbEEyUXJ6Q0hEd1FjMFY3bE5FczNWK01TMHBhR0pZcm42OHQ2ODBjVVZYRUFzTnU5dXpMeUpXTHdIdkp5VDRob044alBIMUhjRGJwTW1yRE1oUG9oQ20zUjdkYWFQM0VDcG9EZ0J2dDMrNmVjbmk5c1V4VVk2VEt3TGcxekg"
    },
    {
      name: "iMac",
      price: 41_499_000,
      description: "Máy tính tất cả trong một tuyệt đẹp với màn hình Retina 4.5K 24 inch sống động và sắc màu rực rỡ.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/imac-digitalmat-gallery-2-202410?wid=728&hei=666&fmt=png-alpha&.v=OURsbmhReXErU1E1S050OGsrUXJyZUtjRVR0S0dVNVlOdVhpNlMwWjcrd1RDMFgyWE5CaGc1dHIrSkVKb1NNV1M0TjRWdzF2UjRGVEY0c3dBQVZ6VFYzenVkeExHQ2RFQW5HS2lnQkVmQkk"
    },
    {
      name: "Mac mini",
      price: 14_999_000,
      description: "Kích thước nhỏ gọn đáng kinh ngạc, sẵn sàng biến mọi bàn làm việc thành không gian sáng tạo mạnh mẽ.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/mac-mini-digitalmat-gallery-3-202608?wid=728&hei=666&fmt=png-alpha&.v=d0pHanlhcjRCaXUzUWJNdzlDWFl6aHlVUVRHTkd5alQ5aFd0OWdSZUk0SWR4Tzlab0J0a1RjRmF1OFdKanZSUjJSWWg0TDRLSXM4czBZQjZvUHdsVE02Z25ENzBXdDNubERIZ041cmwwbE9pUzFWRGpRKzBmMnZrV0JNa0htekc"
    },
    {
      name: "Mac Studio",
      price: 55_999_000,
      description: "Trạm năng lượng sáng tạo tối thượng với các cổng kết nối đa dạng và sức mạnh xử lý vượt mọi giới hạn.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/mac-studio-digitalmat-gallery-4-202608?wid=728&hei=666&fmt=png-alpha&.v=QzEyV0dJWlhXQnhCQVZWR1lsdnBRQ29tZGFRcVl5Vm12RlEvdm1xNU1vczE0MmtkTGZHZm9HcHdpZ3A1czQ4Tmt6cS95dmlBOWw0UXFnT0NPVW5rUnpEN2dSNWFVNVVLTGdYUXA1ZllpZXpkNFpMU0V3U2hrTUg1VWcwc3ptV2k"
    },
    {
      name: "Studio Display",
      price: 39_999_000,
      description: "Màn hình Retina 5K 27 inch tuyệt đẹp cùng camera 12MP góc siêu rộng hỗ trợ tính năng Center Stage.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/studio-display-digitalmat-gallery-1-202603?wid=728&hei=666&fmt=png-alpha&.v=eHlKZk4xMFRaTnVqRExtOHhhVk5YVWEvQmI5ZjZseVhPSEJZVkYxZ09Jc1B4RUFjdlp5bWdtaWlNUUdRclhtVHhaVXN2UmVLZWxyY01GTDZmcDYxbnl5cS9yQWgvZTlTbm9pYWIyd3NrUEk0Y3M5N01QTytJbGdTa2c0blpQZmo"
    },
    {
      name: "Studio Display XDR",
      price: 129_999_000,
      description: "Màn hình chuyên nghiệp Pro Display XDR 32 inch với độ sáng 1.600 nit và độ chuẩn màu tuyệt đối.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/studio-display-xdr-digitalmat-gallery-1-202603?wid=728&hei=666&fmt=jpeg&qlt=90&.v=SDI3bHBhRUtmQXpXUFEvQzliRVR6RitybDAvRGJwWTBJN1BpQm9pLzNOcXVVSnVvd25hTVZ4OHlDcW9LUEhPeGVkZGptNUJaWitJZ3gyOURkSTlZQ3I2TGhYaGhMVkJpQ2RGWWVURTZNbXpjaU5kcUJRTFo3ck1mckRNaHhINkQ"
    }
  ],
  "iPhone" => [
    {
      name: "iPhone Duo",
      price: 42_999_000,
      description: "Dòng máy gập concept mới mang tính cách mạng, kết hợp màn hình ngoài sắc nét và màn hình gập đôi linh hoạt.",
      image_source: "https://www.apple.com/autopush/ww/search/modules/iphoneduo/image__ec3lc7c1x6eu_large_2x.jpg"
    },
    {
      name: "iPhone 18 Pro",
      price: 34_999_000,
      description: "Concept mới với khung titan cấp hàng không vũ trụ, chip A-series Pro và hệ thống camera tiềm vọng tiên tiến.",
      image_source: "https://www.apple.com/autopush/ww/search/modules/iphone18pro/image__co2ner2xfqmq_large_2x.jpg"
    },
    {
      name: "iPhone Air",
      price: 27_999_000,
      description: "Độ mỏng kỷ lục, thiết kế thanh lịch siêu nhẹ cùng màn hình ProMotion 120Hz mượt mà.",
      image_source: "https://www.apple.com/v/iphone/home/ck/images/overview/chapternav/iphone_air__b5qmgl05ojyq_large_2x.png"
    },
    {
      name: "iPhone 17",
      price: 24_999_000,
      description: "Bước nhảy vọt về hiệu năng, màu sắc trẻ trung, hệ thống camera kép 48MP và Apple Intelligence.",
      image_source: "https://www.apple.com/vn/iphone/home/images/overview/chapternav/iphone_17__fb1277oq3eaa_large_2x.png"
    },
    {
      name: "iPhone 17e",
      price: 16_999_000,
      description: "Phiên bản thiết yếu nhỏ gọn, tích hợp trọn vẹn những công nghệ cốt lõi của Apple với mức giá dễ tiếp cận.",
      image_source: "https://www.apple.com/vn/iphone/home/images/overview/chapternav/iphone_17e__cq5ygzct314y_large_2x.png"
    },
    {
      name: "iPhone 16",
      price: 21_999_000,
      description: "Trang bị nút Điều Khiển Camera mới, chip A18 mạnh mẽ và thời lượng pin được tối ưu vượt bậc.",
      image_source: "https://www.apple.com/vn/iphone/home/images/overview/chapternav/iphone_16__b6tkv86m2gc2_large_2x.png"
    }
  ],
  "iPad" => [
    {
      name: "iPad Pro",
      price: 28_999_000,
      description: "Màn hình Ultra Retina XDR công nghệ Tandem OLED đột phá cùng sức mạnh không tưởng từ chip Apple M4.",
      image_source: "https://www.apple.com/assets-www/en_WW/ipad/03_chapternav/small/ipad_pro_bd732ab83_2x.png"
    },
    {
      name: "iPad Air",
      price: 16_999_000,
      description: "Đa năng, mỏng nhẹ với 2 kích thước màn hình, trang bị chip M2 và hỗ trợ Apple Pencil Pro.",
      image_source: "https://www.apple.com/assets-www/en_WW/ipad/03_chapternav/small/ipad_air_1ebbfa37b_2x.png"
    },
    {
      name: "iPad",
      price: 9_999_000,
      description: "Chiếc iPad màn hình tràn viền rực rỡ, hoàn hảo cho các tác vụ học tập, làm việc và giải trí hàng ngày.",
      image_source: "https://www.apple.com/assets-www/en_WW/ipad/03_chapternav/small/ipad_473e5c831_2x.png"
    },
    {
      name: "iPad mini",
      price: 13_999_000,
      description: "Sức mạnh khổng lồ trong thiết kế nhỏ gọn 8.3 inch, dễ dàng cầm gọn và thao tác chỉ bằng một tay.",
      image_source: "https://www.apple.com/assets-www/en_WW/ipad/03_chapternav/small/ipad_mini_f62883aa9_2x.png"
    }
  ],
  "Apple Watch" => [
    {
      name: "Apple Watch Series 12",
      price: 10_999_000,
      description: "Mẫu mới nhất với cảm biến theo dõi sức khỏe đột phá, đo điện tâm đồ và màn hình viền siêu mỏng.",
      image_source: "https://www.apple.com/assets-www/vi_VN/watch/chapternav/small/nav_s12_7449495ab_2x.png"
    },
    {
      name: "Apple Watch Ultra 4",
      price: 21_999_000,
      description: "Mẫu mới nhất chuyên dụng cho thể thao mạo hiểm với vỏ titan 49mm, pin bền bỉ và GPS tần số kép.",
      image_source: "https://www.apple.com/assets-www/vi_VN/watch/chapternav/small/nav_ultra4_592b10e98_2x.png"
    },
    {
      name: "Apple Watch SE 3",
      price: 6_399_000,
      description: "Đầy đủ các tính năng an toàn, theo dõi vận động thể chất với mức giá khởi điểm vô cùng hợp lý.",
      image_source: "https://www.apple.com/assets-www/vi_VN/watch/chapternav/small/nav_se3_2234ed587_2x.png"
    },
    {
      name: "Apple Watch Nike",
      price: 11_499_000,
      description: "Phiên bản thể thao hợp tác độc quyền cùng Nike với mặt đồng hồ chuyên biệt và dây đeo thể thao thoáng khí.",
      image_source: "https://www.apple.com/assets-www/vi_VN/watch/chapternav/small/nav_nike_fa63e8ff1_2x.png"
    }
  ],
  "AirPods" => [
    {
      name: "AirPods 5 (Chủ động khử tiếng ồn)",
      price: 3_799_000,
      description: "Thiết kế công thái học hiện đại tích hợp công nghệ chống ồn chủ động (ANC) và chip âm thanh H2 tân tiến.",
      image_source: "https://www.apple.com/v/airpods-5/a/images/overview/contrast/explore_airpods_5_in__gadkl3bf562y_xlarge_2x.jpg"
    },
    {
      name: "AirPods Pro",
      price: 6_199_000,
      description: "Chống ồn chủ động vượt trội gấp 2 lần, tính năng Nhận Biết Cuộc Hội Thoại và chuẩn kháng bụi nước IP54.",
      image_source: "https://www.apple.com/v/airpods-pro/t/images/overview/battery/case__b87ou7jna9de_large_2x.png"
    },
    {
      name: "AirPods Max",
      price: 13_999_000,
      description: "Tai nghe over-ear cao cấp với âm thanh Hi-Fi trung thực chuẩn phòng thu, đệm tai dạng lưới thoáng khí sang trọng.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/airpods-max-hero-select-202409?wid=976&hei=916&fmt=jpeg&qlt=90&.v=WXBZVEZCOUNiUWlBYUtjZmtBc0J2N1V1ZldxRmdZVjlvL2IxaEY3dzY3SG0ybW5TK3prTnlNTURRc1V2clYydHZvdUZlR0V0VUdJSjBWaDVNVG95YkJTUUExTVpiaXRIUnFOM1YxY0hPWFU"
    }
  ],
  "TV & Nhà" => [
    {
      name: "Apple TV 4K",
      price: 5_999_000,
      description: "Trải nghiệm điện ảnh đỉnh cao tại nhà với chất lượng hình ảnh 4K Dolby Vision và âm thanh vòm Dolby Atmos sống động.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/apple-tv-4k-hero-select-202210?wid=1076&hei=1070&fmt=jpeg&qlt=90&.v=a3VoZW85YUhreXN3ZFlSUDc3a0tqdU1qeWRTYWRhVU5NM3d6SkhmNzkxTVA2eHYwV0FuTVcxeXpzZU1sNHk2WmJGcXNRQnFCV0w3WVRjTExvdm1ic2FNaUdBMSt0VkxKZ2NWelk1alBpUVVXZEdHNUFPR0hYUU12cjI0VlFzM1A"
    }
  ],
  "Phụ kiện" => [
    {
      name: "AirTag",
      price: 799_000,
      description: "Thiết bị theo dõi nhỏ gọn giúp định vị chìa khóa, ví tiền và hành lý thông qua mạng lưới Find My rộng khắp.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/airtag-1pack-select-202601?wid=940&hei=1112&fmt=png-alpha&.v=eVZIdm00RE01SWs3QURJMUxNRitlUUZRNU9LNkVNWnlXdGtyVWlDRm54QmZhS1VCT1k0VG5wendIdURyT0d4ZURrcnNsQUdJUGlKTENUeG5lbFJUV0Y0dnJSYzFEb21pLzZjOUEzZEtaSkk"
    },
    {
      name: "Tai nghe Beats",
      price: 4_499_000,
      description: "Âm trầm mạnh mẽ, thiết kế thời trang đậm chất đường phố và kết nối liền mạch cùng hệ sinh thái Apple.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MJE14?wid=1144&hei=1144&fmt=jpeg&qlt=90&.v=UWMvdXJJbEY3ODZGdGxuTlY3UGxvQWtuVHYzMERCZURia3c5SzJFOTlPaXlCTlZFYitFVTRocVY3K3NxVzBJQnFHaTVPRGlzeW5kL01hRlNZdHZUMXc"
    },
    {
      name: "Apple Pencil",
      price: 2_199_000,
      description: "Bút cảm ứng với độ chính xác đến từng điểm ảnh, độ nhạy góc nghiêng và lực nhấn hoàn hảo cho ghi chú và vẽ.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MX2D3?wid=1144&hei=1144&fmt=jpeg&qlt=90&.v=aERwRkppV2pTZWx2MDU5ek9FWVpkd2tuVHYzMERCZURia3c5SzJFOTlPamtyK21QQVlqVGgrcGQ5Uy9BWWRGOUU5TjEzNDVxWGZyenF5K251RnVTZXc"
    },
    {
      name: "Magic Keyboard",
      price: 2_999_000,
      description: "Bàn phím không dây với cơ chế cắt kéo êm ái, pin sạc bền bỉ và tích hợp cảm biến vân tay Touch ID bảo mật.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MXCK3?wid=890&hei=890&fmt=jpeg&qlt=90&.v=RnJQQkhwOG5HUE9uYzJheGNxQTR3NHExblZJSGFXSFVPMUE2c2RxMy8rS2xCTS9WVlZxQiszTStzWVkrdlRCS3IzM3B6ZUp5MkY2V20xdmord3d6TUE"
    },
    {
      name: "Củ sạc 20W",
      price: 550_000,
      description: "Củ sạc nhanh USB-C 20W chính hãng Apple, hỗ trợ Power Delivery sạc 50% pin cho iPhone trong 30 phút.",
      image_source: "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MD3J4?wid=890&hei=890&fmt=jpeg&qlt=90&.v=OFlNZlJtMmlGVU5hQlBKdXh1dDBRWXExblZJSGFXSFVPMUE2c2RxMy8rTHVSM0FUWFppbmsvSE95N1dldU1CZnM5YTZvOGw5WW9PMGpTeTYyWldRcWc"
    }
  ]
}

# 2. Tạo/Cập nhật dữ liệu và đính kèm hình ảnh
total_products = 0

catalog_data.each do |cat_name, products|
  category_record = nil
  if has_category_model
    category_record = Category.find_or_create_by!(name: cat_name)
  end

  category_slug = CATEGORY_SLUGS[cat_name] || cat_name.parameterize.underscore
  puts "\n📁 [Danh mục] #{cat_name}"

  products.each do |prod_attrs|
    product = Product.find_or_initialize_by(name: prod_attrs[:name])
    product.price = prod_attrs[:price]
    product.description = prod_attrs[:description]

    product.category_id = category_record.id if has_category_id_col && category_record
    product.category    = category_slug if has_category_col

    # Nếu có cột image_url trong bảng Product, cập nhật luôn URL gốc
    if has_image_url_col
      product.image_url = prod_attrs[:image_source]
    end

    product.save!

    # Tải và đính kèm ảnh thật vào ActiveStorage (Product#image)
    attach_image(product, prod_attrs[:image_source])

    total_products += 1
    formatted_price = product.price.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    puts "  ✓ #{product.name.ljust(35)} | #{formatted_price.rjust(12)} đ"
  end
end

puts "\n🎉 Cập nhật hoàn tất! Tổng cộng: #{total_products} sản phẩm đã có ảnh."
