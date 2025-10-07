class EmailProcessor
  PARSERS = [
    Parsers::SupplierAParser,
    Parsers::PartnerBParser
  ].freeze

  def initialize(ingested_email_id)
    @ingested_email = IngestedEmail.find(ingested_email_id)
  end

  def call
    @ingested_email.update!(status: :processing)

    begin
      mail = load_mail
      parser = find_parser(mail)
      
      if parser.nil?
        handle_parser_not_found(mail)
        return
      end

      extracted_data = parser.call
      
      if extracted_data[:email].blank? && extracted_data[:phone].blank?
        handle_no_contact_data(parser, extracted_data)
        return
      end

      create_customer(extracted_data)
      create_success_log(parser, extracted_data)
      @ingested_email.update!(status: :success)

    rescue => e
      handle_processing_error(e)
    end
  end

  private

  def load_mail
    file_content = @ingested_email.file_content
    raise 'No file attached' if file_content.blank?

    Mail.read_from_string(file_content)
  end

  def find_parser(mail)
    sender_domain = extract_domain(mail.from&.first)
    
    parser_class = PARSERS.find do |p|
      p.matches?(mail, sender_domain)
    end
    
    parser_class&.new(mail) if parser_class
  end

  def extract_domain(email)
    return nil if email.blank?
    
    email.split('@').last&.downcase
  end

  def create_customer(extracted_data)
    Customer.create!(
      name: extracted_data[:name],
      email: extracted_data[:email],
      phone: extracted_data[:phone],
      product_code: extracted_data[:product_code],
      subject: extracted_data[:subject]
    )
  end

  def create_success_log(parser, extracted_data)
    ProcessingLog.create!(
      ingested_email: @ingested_email,
      parser: parser.name,
      status: :success,
      extracted_payload: extracted_data
    )
  end

  def handle_parser_not_found(mail)
    error_message = "No parser found for sender: #{mail.from&.first}"
    
    ProcessingLog.create!(
      ingested_email: @ingested_email,
      parser: 'Unknown',
      status: :failure,
      extracted_payload: { sender: mail.from&.first, subject: mail.subject },
      error_message: error_message
    )
    
    @ingested_email.update!(
      status: :failed,
      error_message: error_message
    )
  end

  def handle_no_contact_data(parser, extracted_data)
    error_message = 'No contact information (email or phone) found in email'
    
    ProcessingLog.create!(
      ingested_email: @ingested_email,
      parser: parser.name,
      status: :failure,
      extracted_payload: extracted_data,
      error_message: error_message
    )
    
    @ingested_email.update!(
      status: :failed,
      error_message: error_message
    )
  end

  def handle_processing_error(error)
    error_message = "Processing error: #{error.message}"
    
    ProcessingLog.create!(
      ingested_email: @ingested_email,
      parser: 'EmailProcessor',
      status: :failure,
      extracted_payload: {},
      error_message: "#{error_message}\n#{error.backtrace.first(5).join("\n")}"
    )
    
    @ingested_email.update!(
      status: :failed,
      error_message: error_message
    )
  end
end
