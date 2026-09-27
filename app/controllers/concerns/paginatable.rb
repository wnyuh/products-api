# Phân trang bằng page/per_page. Thông tin trang nằm ở header, thân response giữ nguyên là mảng:
#   X-Total-Count, X-Page, X-Per-Page và Link (RFC 8288: first/prev/next/last)
# Dùng Pagy (https://github.com/ddnexus/pagy) để tính offset/limit/last_page/prev/next
# thay vì tự viết. KHÔNG dùng header/Link builder có sẵn của Pagy: mặc định nó build URL
# TUYỆT ĐỐI từ request.base_url (phản chiếu Host client gửi) — không đạt yêu cầu bảo mật
# đã verify ở phase 02 (Link phải là đường dẫn tương đối).
module Paginatable
  extend ActiveSupport::Concern
  include Pagy::Method

  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  private

  def paginate(scope)
    # to_s.to_i để page[]=1 hay page[x]=1 không làm nổ 500
    page = [ params[:page].to_s.to_i, 1 ].max
    per_page = (params[:per_page].presence&.to_s&.to_i || DEFAULT_PER_PAGE).clamp(1, MAX_PER_PAGE)

    # page/limit truyền tay (không phải :client_limit) nên Pagy không tự đọc lại params —
    # giữ nguyên đúng ngữ nghĩa clamp ở trên (per_page=0 -> 1, per_page=1000 -> 100).
    pagy_data, records = pagy(scope, page: page, limit: per_page)

    response.set_header("X-Total-Count", pagy_data.count.to_s)
    response.set_header("X-Page", pagy_data.page.to_s)
    response.set_header("X-Per-Page", pagy_data.limit.to_s)
    response.set_header("Link", pagination_links(pagy_data))

    records
  end

  # Dùng đường dẫn tương đối để không phản chiếu header Host do client gửi
  def pagination_links(pagy_data)
    pages = { first: 1, last: pagy_data.pages }
    pages[:prev] = pagy_data.previous if pagy_data.previous
    pages[:next] = pagy_data.next if pagy_data.next

    pages.map do |rel, number|
      query = request.query_parameters.merge("page" => number, "per_page" => pagy_data.limit).to_query
      %(<#{request.path}?#{query}>; rel="#{rel}")
    end.join(", ")
  end
end
