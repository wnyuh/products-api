# Phân trang bằng page/per_page. Thông tin trang nằm ở header, thân response giữ nguyên là mảng:
#   X-Total-Count, X-Page, X-Per-Page và Link (RFC 8288: first/prev/next/last)
module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  private

  def paginate(scope)
    # to_s.to_i để page[]=1 hay page[x]=1 không làm nổ 500
    page = [ params[:page].to_s.to_i, 1 ].max
    per_page = (params[:per_page].presence&.to_s&.to_i || DEFAULT_PER_PAGE).clamp(1, MAX_PER_PAGE)
    total = scope.count
    last_page = [ (total.to_f / per_page).ceil, 1 ].max

    response.set_header("X-Total-Count", total.to_s)
    response.set_header("X-Page", page.to_s)
    response.set_header("X-Per-Page", per_page.to_s)
    response.set_header("Link", pagination_links(page, per_page, last_page))

    scope.limit(per_page).offset((page - 1) * per_page)
  end

  # Dùng đường dẫn tương đối để không phản chiếu header Host do client gửi
  def pagination_links(page, per_page, last_page)
    pages = { first: 1, last: last_page }
    pages[:prev] = page - 1 if page > 1
    pages[:next] = page + 1 if page < last_page

    pages.map do |rel, number|
      query = request.query_parameters.merge("page" => number, "per_page" => per_page).to_query
      %(<#{request.path}?#{query}>; rel="#{rel}")
    end.join(", ")
  end
end
