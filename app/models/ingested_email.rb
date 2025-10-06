class IngestedEmail < ApplicationRecord
  has_many :processing_logs, dependent: :destroy
  has_one_attached :file

  enum status: {
    queued: 0,
    processing: 1,
    success: 2,
    failed: 3
  }

  validates :sender, presence: true
  validates :subject, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  def file_content
    return nil unless file.attached?
    
    file.blob.download
  end

  def processing_duration
    return nil unless success? || failed?
    
    processing_logs.maximum(:created_at) - created_at
  end
end
