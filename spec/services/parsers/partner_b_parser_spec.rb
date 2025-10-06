require 'rails_helper'

RSpec.describe Parsers::PartnerBParser do
  let(:parser) { described_class }

  describe '.matches?' do
    it 'matches parceirob.com domain' do
      mail = double(from: ['test@parceirob.com'])
      expect(parser.matches?(mail, 'parceirob.com')).to be true
    end

    it 'does not match other domains' do
      mail = double(from: ['test@example.com'])
      expect(parser.matches?(mail, 'example.com')).to be false
    end
  end

  describe '#call' do
    let(:mail) { double(subject: 'Test Subject', multipart?: false, decoded: email_body) }
    let(:parser_instance) { described_class.new(mail) }

    context 'with complete email body' do
      let(:email_body) do
        <<~EMAIL
          Nome do Cliente: Carlos Mendes
          Email: carlos@partner.com
          Telefone: (21) 99999-9999
          Código do Produto: PARTNER-456
          
          Detalhes adicionais do pedido.
        EMAIL
      end

      it 'extracts all data correctly' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Carlos Mendes')
        expect(result[:email]).to eq('carlos@partner.com')
        expect(result[:phone]).to eq('5521999999999')
        expect(result[:product_code]).to eq('PARTNER-456')
        expect(result[:subject]).to eq('Test Subject')
      end
    end

    context 'with alternative patterns' do
      let(:email_body) do
        <<~EMAIL
          Contato: Dra. Fernanda Lima
          E-mail: fernanda@business.com
          Celular: 21 8888-8888
          SKU: P-B-789
        EMAIL
      end

      it 'extracts data with alternative patterns' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Dra. Fernanda Lima')
        expect(result[:email]).to eq('fernanda@business.com')
        expect(result[:phone]).to eq('552188888888')
        expect(result[:product_code]).to eq('P-B-789')
      end
    end

    context 'with responsible field' do
      let(:email_body) do
        <<~EMAIL
          Responsável: Roberto Silva
          Email: roberto@company.com
          Telefone: (11) 7777-7777
          Item: RESP-123
        EMAIL
      end

      it 'extracts data from responsible field' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Roberto Silva')
        expect(result[:email]).to eq('roberto@company.com')
        expect(result[:phone]).to eq('551177777777')
        expect(result[:product_code]).to eq('RESP-123')
      end
    end

    context 'with international phone format' do
      let(:email_body) do
        <<~EMAIL
          Nome: International Client
          Email: client@global.com
          Contato: +1 555 123 4567
          Produto: GLOBAL-999
        EMAIL
      end

      it 'handles international phone numbers' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('International Client')
        expect(result[:email]).to eq('client@global.com')
        expect(result[:phone]).to eq('15551234567')
        expect(result[:product_code]).to eq('GLOBAL-999')
      end
    end

    context 'with alphanumeric product codes' do
      let(:email_body) do
        <<~EMAIL
          Nome: Test Client
          Email: test@example.com
          Telefone: 11 9999-9999
          Código: ABC123DEF
        EMAIL
      end

      it 'extracts alphanumeric codes' do
        result = parser_instance.call
        
        expect(result[:product_code]).to eq('ABC123DEF')
      end
    end

    context 'with missing data' do
      let(:email_body) do
        <<~EMAIL
          Nome do Cliente: Incomplete Data
          Mensagem: Sem informações de contato.
        EMAIL
      end

      it 'returns nil for missing fields' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Incomplete Data')
        expect(result[:email]).to be_nil
        expect(result[:phone]).to be_nil
        expect(result[:product_code]).to be_nil
      end
    end
  end
end
