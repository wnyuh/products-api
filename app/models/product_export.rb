# Một yêu cầu export: theo dõi trạng thái và giữ file CSV kết quả
class ProductExport < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  # Đường đi của trạng thái: pending → processing → done hoặc failed
  enum :status, { pending: "pending", processing: "processing", done: "done", failed: "failed" }

  def start!
    processing!
  end

  # Ghi thời điểm hoàn thành cùng lúc với trạng thái để không có bản ghi done mà thiếu completed_at
  def complete!
    update!(status: :done, completed_at: Time.current)
  end

  # Lưu lý do lỗi để client biết vì sao export thất bại
  def mark_failed!(message)
    update!(status: :failed, error_message: message, completed_at: Time.current)
  end
end
