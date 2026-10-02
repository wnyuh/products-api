# Dữ liệu mẫu cho demo storefront. Idempotent + gắn ảnh còn thiếu khi chạy lại.
# image_source: link ảnh thật (thumbnail Google/bizweb) — seed tải về rồi attach vào ActiveStorage (Product#image).
# Chỉ tải khi sản phẩm chưa có ảnh; lỗi mạng chỉ cảnh báo, không làm hỏng seed.
require "open-uri"

def attach_image(product, source)
  return if product.image.attached?

  io = URI.parse(source).open(open_timeout: 10, read_timeout: 20)
  extension = MiniMime.lookup_by_content_type(io.content_type)&.extension || "jpg"
  product.image.attach(io: io, filename: "#{product.name.parameterize}.#{extension}", content_type: io.content_type)
rescue StandardError => e
  warn "Không tải được ảnh cho #{product.name}: #{e.message}"
end

[
  { name: "Ốp lưng silicon iPhone 15",         category: "case",             price: 250_000, description: "Ốp silicon mềm, chống bám vân tay.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQp6MJh3F635ksnpWK9MVJ9rURaubI604DXJ0ulkJ50RA&s=10" },
  { name: "Ốp lưng trong suốt MagSafe",         category: "case",             price: 390_000, description: "Trong suốt, hỗ trợ sạc MagSafe.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMGHZszw6nBfCD2SXzKm9f3LjxUxzW8Co9XX5x8xY6Jw&s=10" },
  { name: "Ốp lưng da iPhone 15 Pro",           category: "case",             price: 690_000, description: "Da thật, ôm sát máy.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSh4QA4m5BxeB8nVBQ2q8MTqwu8q7cL9fUjnF9HZ71F5w&s=10" },
  { name: "Ốp chống sốc viền cao su",           category: "case",             price: 320_000, description: nil, image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3u0_qLHiQt1mLs-DPtWfgebK2t9aazuecjQkJR-9-Yw&s" },
  { name: "Củ sạc nhanh 20W USB-C",             category: "charger",          price: 450_000, description: "Sạc nhanh 50% trong 30 phút.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQr5dJqGA9OebEcX5BFGPp5rR95ZsRhd0FWZHe7Gv1REQ&s" },
  { name: "Củ sạc GaN 35W hai cổng",            category: "charger",          price: 790_000, description: "Nhỏ gọn, sạc 2 thiết bị cùng lúc.", image_source: "https://bizweb.dktcdn.net/thumb/1024x1024/100/453/032/products/5-b32739f5-614f-4a27-83c2-f1e147ce6509.jpg?v=1734081615850" },
  { name: "Đế sạc MagSafe 15W",                 category: "charger",          price: 990_000, description: "Sạc không dây hít nam châm.", image_source: "https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcSbshYSxIqgedTlruXsi1ibuOh6ldDM_sa6SkLmT4cHuBSs4lO-v3L8Yqb128J3B9eJaB1CU4WihzmQ0aFyRE8mE8VriA9djlXLG-2qeV67xlC7XyFFMZKUJA" },
  { name: "Sạc dự phòng 10000mAh",              category: "charger",          price: 590_000, description: nil, image_source: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcTgI2KpNP-SuNvRhIHG5okQnpghiniw6f1uVuivS66q3LNDy79eVfZ4PveJnTLOnsJM4A-r3c_lAfdIdwTSD7yKV1rVOPwUEpAeRM_-VGtgDWE1lTNKEu9U" },
  { name: "Cáp USB-C to USB-C 1m",              category: "cable",            price: 190_000, description: "Bện dù, bền.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRcJSMVme7wp3_9xKk5qRWE2ZPkXqWBOVj_tk1x5EYrRg&s" },
  { name: "Cáp USB-C to Lightning 1m",          category: "cable",            price: 290_000, description: "Chứng nhận MFi.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8WmIWZuXWSbAHDMXKFwvDvXLxef-je_nQl2xmYhyiEw&s=10" },
  { name: "Cáp USB-C 2m sạc nhanh 60W",         category: "cable",            price: 350_000, description: nil, image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTn1itDKmtmvmwdEqPZdLDcnZfkjqgSsU1rusIdio1TCw&s" },
  { name: "Kính cường lực iPhone 15",           category: "screen_protector", price: 150_000, description: "Độ cứng 9H, full màn.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrjDv0ymP7MS24x2iXA1qxoP3il6BURp-x4Oqjhgf0dg&s=10" },
  { name: "Kính chống nhìn trộm iPhone 15 Pro", category: "screen_protector", price: 280_000, description: "Chống nhìn trộm góc nghiêng.", image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQU0Ulhke470Ao_hG4E94ON6Ogz0AE_ONR84sO0akZU4Q&s=10" },
  { name: "Dán camera sau iPhone 15 Pro Max",   category: "screen_protector", price: 120_000, description: nil, image_source: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS55AsyK3FoSbN3Jk4KngIMi0IUB1FkORcZP04ELy4PCA&s=10" }
].each do |attrs|
  product = Product.find_or_initialize_by(name: attrs[:name])
  product.update!(attrs.except(:image_source))
  attach_image(product, attrs[:image_source])
end

puts "Seeded. Tổng số Product: #{Product.count}"
