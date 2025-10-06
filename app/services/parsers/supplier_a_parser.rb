class Parsers::SupplierAParser < Parsers::BaseParser
  def self.matches?(mail, sender_domain)
    sender_domain&.include?('fornecedora.com')
  end

  private

  def extract_name
    # Look for name patterns in the email body
    body = clean_html(email_body)
    
    # Pattern: "Nome: João Silva" or "Cliente: Maria Santos"
    name_match = body.match(/(?:nome|cliente)[\s:]+([a-záàâãéèêíïóôõöúçñ\s]+)/i)
    return name_match[1].strip if name_match
    
    # Pattern: "Sr(a). João Silva" or "Dr(a). Maria Santos"
    title_match = body.match(/(?:sr|sra|dr|dra)\.?\s+([a-záàâãéèêíïóôõöúçñ\s]+)/i)
    return title_match[1].strip if title_match
    
    nil
  end

  def extract_email
    body = clean_html(email_body)
    
    # Look for email patterns
    email_match = body.match(/(?:email|e-mail)[\s:]+([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i)
    return email_match[1] if email_match
    
    # Look for any email in the body
    email_match = body.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/)
    return email_match[1] if email_match
    
    nil
  end

  def extract_phone
    body = clean_html(email_body)
    
    # Look for phone patterns
    phone_match = body.match(/(?:telefone|fone|celular|whatsapp)[\s:]+([\d\s\(\)\-\+]+)/i)
    return normalize_phone(phone_match[1]) if phone_match
    
    # Look for Brazilian phone patterns
    phone_match = body.match(/(?:\(?\d{2}\)?\s?)?(?:9\s?)?\d{4}[\s\-]?\d{4}/)
    return normalize_phone(phone_match[0]) if phone_match
    
    nil
  end

  def extract_product_code
    body = clean_html(email_body)
    
    # Look for product code patterns
    code_match = body.match(/(?:código|codigo|produto|item)[\s:]+([A-Z0-9\-]{3,})/i)
    return code_match[1].upcase if code_match
    
    # Look for patterns like "PROD-123" or "ABC123"
    code_match = body.match(/([A-Z]{2,}[\-\_]?\d{2,})/i)
    return code_match[1].upcase if code_match
    
    nil
  end
end
