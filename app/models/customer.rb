class Customer < ApplicationRecord
  validates :email, presence: true, if: -> { phone.blank? }
  validates :phone, presence: true, if: -> { email.blank? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  validate :has_contact_information
  
  private
  
  def has_contact_information
    if email.blank? && phone.blank?
      errors.add(:base, "Must have either email or phone")
    end
  end

  scope :by_email, ->(email) { where('email ILIKE ?', "%#{email}%") }
  scope :by_phone, ->(phone) { where('phone ILIKE ?', "%#{phone}%") }

  def contact_info
    [email, phone].compact.join(' | ')
  end
end
