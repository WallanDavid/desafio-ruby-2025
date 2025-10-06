class ProcessingLog < ApplicationRecord
  belongs_to :ingested_email

  enum status: {
    success: 0,
    failure: 1
  }

  validates :parser, presence: true
  validates :extracted_payload, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_parser, ->(parser) { where(parser: parser) }
  scope :by_status, ->(status) { where(status: status) }

  def extracted_data
    return {} unless extracted_payload.is_a?(Hash)
    
    extracted_payload
  end

  def has_customer_data?
    data = extracted_data
    data['email'].present? || data['phone'].present?
  end
end
