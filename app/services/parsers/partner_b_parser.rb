class Parsers::PartnerBParser < Parsers::BaseParser
  def self.matches?(mail, sender_domain)
    sender_domain&.include?('parceirob.com')
  end

  private

  def extract_name
    body = clean_html(email_body)
    
    # Pattern: "Nome do Cliente: João Silva" or "Cliente: Maria Santos"
    name_match = body.match(/(?:nome\s+do\s+cliente|cliente)[\s:]+([a-záàâãéèêíïóôõöúçñ\s]+)/i)
    return name_match[1].strip if name_match
    
    # Pattern: "Contato: Dr. João Silva"
    contact_match = body.match(/contato[\s:]+(?:dr|dra|sr|sra)\.?\s+([a-záàâãéèêíïóôõöúçñ\s]+)/i)
    return contact_match[1].strip if contact_match
    
    # Pattern: "Responsável: Maria Santos"
    responsible_match = body.match(/responsável[\s:]+([a-záàâãéèêíïóôõöúçñ\s]+)/i)
    return responsible_match[1].strip if responsible_match
    
    nil
  end

  def extract_email
    body = clean_html(email_body)
    
    # Look for email patterns with labels
    email_match = body.match(/(?:email|e-mail|correio)[\s:]+([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i)
    return email_match[1] if email_match
    
    # Look for any email in the body
    email_match = body.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/)
    return email_match[1] if email_match
    
    nil
  end

  def extract_phone
    body = clean_html(email_body)
    
    # Look for phone patterns with labels
    phone_match = body.match(/(?:telefone|fone|celular|whatsapp|contato)[\s:]+([\d\s\(\)\-\+]+)/i)
    return normalize_phone(phone_match[1]) if phone_match
    
    # Look for Brazilian phone patterns with area codes
    phone_match = body.match(/(?:\(?\d{2}\)?\s?)?(?:9\s?)?\d{4}[\s\-]?\d{4}/)
    return normalize_phone(phone_match[0]) if phone_match
    
    # Look for international format
    phone_match = body.match(/(\+\d{1,3}[\s\-]?)?\d{10,15}/)
    return normalize_phone(phone_match[0]) if phone_match
    
    nil
  end

  def extract_product_code
    body = clean_html(email_body)
    
    # Look for product code patterns with labels
    code_match = body.match(/(?:código|codigo|produto|item|sku)[\s:]+([A-Z0-9\-]{3,})/i)
    return code_match[1].upcase if code_match
    
    # Look for patterns like "P-B-123" or "PARTNER-ABC123"
    code_match = body.match(/([A-Z]{2,}[\-\_]?\d{2,})/i)
    return code_match[1].upcase if code_match
    
    # Look for alphanumeric codes
    code_match = body.match(/([A-Z0-9]{4,})/i)
    return code_match[1].upcase if code_match && code_match[1].length >= 4
    
    nil
  end
end
