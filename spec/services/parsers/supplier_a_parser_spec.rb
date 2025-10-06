require 'rails_helper'

RSpec.describe Parsers::SupplierAParser do
  let(:parser) { described_class }

  describe '.matches?' do
    it 'matches fornecedora.com domain' do
      mail = double(from: ['test@fornecedora.com'])
      expect(parser.matches?(mail, 'fornecedora.com')).to be true
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
          Nome: João Silva
          Email: joao@example.com
          Telefone: (11) 99999-9999
          Código do Produto: PROD-123
          
          Mensagem adicional aqui.
        EMAIL
      end

      it 'extracts all data correctly' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('João Silva')
        expect(result[:email]).to eq('joao@example.com')
        expect(result[:phone]).to eq('5511999999999')
        expect(result[:product_code]).to eq('PROD-123')
        expect(result[:subject]).to eq('Test Subject')
      end
    end

    context 'with HTML email body' do
      let(:email_body) do
        <<~EMAIL
          <html>
            <body>
              <p>Nome: Maria Santos</p>
              <p>Email: maria@test.com</p>
              <p>Telefone: 11 8888-8888</p>
              <p>Código: ABC-456</p>
            </body>
          </html>
        EMAIL
      end

      it 'extracts data from HTML' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Maria Santos')
        expect(result[:email]).to eq('maria@test.com')
        expect(result[:phone]).to eq('551188888888')
        expect(result[:product_code]).to eq('ABC-456')
      end
    end

    context 'with alternative patterns' do
      let(:email_body) do
        <<~EMAIL
          Cliente: Dr. Pedro Oliveira
          E-mail: pedro@company.com
          Celular: +55 11 7777-7777
          Produto: XYZ789
        EMAIL
      end

      it 'extracts data with alternative patterns' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Dr. Pedro Oliveira')
        expect(result[:email]).to eq('pedro@company.com')
        expect(result[:phone]).to eq('551177777777')
        expect(result[:product_code]).to eq('XYZ789')
      end
    end

    context 'with missing data' do
      let(:email_body) do
        <<~EMAIL
          Nome: Ana Costa
          Mensagem: Olá, como vai?
        EMAIL
      end

      it 'returns nil for missing fields' do
        result = parser_instance.call
        
        expect(result[:name]).to eq('Ana Costa')
        expect(result[:email]).to be_nil
        expect(result[:phone]).to be_nil
        expect(result[:product_code]).to be_nil
      end
    end

    context 'with multipart email' do
      let(:text_part) { double(decoded: 'Nome: Text Part') }
      let(:html_part) { double(decoded: '<p>Nome: HTML Part</p>') }
      let(:mail) do
        double(
          subject: 'Test Subject',
          multipart?: true,
          text_part: text_part,
          html_part: html_part,
          decoded: 'Fallback content'
        )
      end

      it 'prefers text part over HTML part' do
        result = parser_instance.call
        expect(result[:name]).to eq('Text Part')
      end
    end

    context 'with phone number variations' do
      let(:email_body) do
        <<~EMAIL
          Telefone: (11) 99999-9999
          Celular: 11 8888 8888
          WhatsApp: +55 11 7777-7777
        EMAIL
      end

      it 'normalizes phone numbers correctly' do
        result = parser_instance.call
        expect(result[:phone]).to eq('5511999999999')
      end
    end
  end
end
