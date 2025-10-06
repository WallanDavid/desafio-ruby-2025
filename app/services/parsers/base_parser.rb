class Parsers::BaseParser
  def self.matches?(mail, sender_domain)
    raise NotImplementedError, 'Subclasses must implement matches?'
  end

  def self.call(mail)
    new(mail).call
  end

  def initialize(mail)
    @mail = mail
  end

  def call
    {
      name: extract_name,
      email: extract_email,
      phone: extract_phone,
      product_code: extract_product_code,
      subject: extract_subject
    }
  end

  private

  attr_reader :mail

  def extract_name
    raise NotImplementedError, 'Subclasses must implement extract_name'
  end

  def extract_email
    raise NotImplementedError, 'Subclasses must implement extract_email'
  end

  def extract_phone
    raise NotImplementedError, 'Subclasses must implement extract_phone'
  end

  def extract_product_code
    raise NotImplementedError, 'Subclasses must implement extract_product_code'
  end

  def extract_subject
    mail.subject
  end

  def email_body
    @email_body ||= begin
      if mail.multipart?
        # Try to get text/plain first, fallback to text/html
        text_part = mail.text_part || mail.html_part
        text_part&.decoded || mail.decoded
      else
        mail.decoded
      end
    end
  end

  def clean_html(html)
    return html unless html.include?('<')
    
    # Simple HTML tag removal
    html.gsub(/<[^>]*>/, '').strip
  end

  def normalize_phone(phone)
    return nil if phone.blank?
    
    # Remove all non-digit characters except +
    cleaned = phone.gsub(/[^\d+]/, '')
    
    # Add country code if missing (assuming Brazil +55)
    if cleaned.length == 11 && cleaned.start_with?('11', '21', '31', '41', '47', '48', '51', '61', '62', '71', '81', '85')
      cleaned = "55#{cleaned}"
    end
    
    cleaned
  end
end
