require 'rails_helper'

RSpec.describe EmailProcessor do
  let(:ingested_email) { create(:ingested_email, :with_file) }
  let(:processor) { described_class.new(ingested_email.id) }

  describe '#call' do
    context 'when email has valid supplier A content' do
      before do
        allow_any_instance_of(Parsers::SupplierAParser).to receive(:call).and_return({
          name: 'João Silva',
          email: 'joao@example.com',
          phone: '11999999999',
          product_code: 'PROD-123',
          subject: 'Test Subject'
        })
      end

      it 'processes email successfully' do
        expect { processor.call }.to change { Customer.count }.by(1)
        
        ingested_email.reload
        expect(ingested_email.status).to eq('success')
        expect(ingested_email.error_message).to be_nil
      end

      it 'creates customer with extracted data' do
        processor.call
        
        customer = Customer.last
        expect(customer.name).to eq('João Silva')
        expect(customer.email).to eq('joao@example.com')
        expect(customer.phone).to eq('11999999999')
        expect(customer.product_code).to eq('PROD-123')
        expect(customer.subject).to eq('Test Subject')
      end

      it 'creates success processing log' do
        processor.call
        
        log = ProcessingLog.last
        expect(log.status).to eq('success')
        expect(log.parser).to eq('Parsers::SupplierAParser')
        expect(log.extracted_payload).to include(
          'name' => 'João Silva',
          'email' => 'joao@example.com'
        )
      end
    end

    context 'when email has no contact information' do
      before do
        allow_any_instance_of(Parsers::SupplierAParser).to receive(:call).and_return({
          name: 'João Silva',
          email: nil,
          phone: nil,
          product_code: 'PROD-123',
          subject: 'Test Subject'
        })
      end

      it 'does not create customer' do
        expect { processor.call }.not_to change { Customer.count }
      end

      it 'marks email as failed' do
        processor.call
        
        ingested_email.reload
        expect(ingested_email.status).to eq('failed')
        expect(ingested_email.error_message).to include('No contact information')
      end

      it 'creates failure processing log' do
        processor.call
        
        log = ProcessingLog.last
        expect(log.status).to eq('failure')
        expect(log.error_message).to include('No contact information')
      end
    end

    context 'when no parser is found' do
      let(:ingested_email) { create(:ingested_email, :with_unknown_sender, :with_file) }

      it 'does not create customer' do
        expect { processor.call }.not_to change { Customer.count }
      end

      it 'marks email as failed' do
        processor.call
        
        ingested_email.reload
        expect(ingested_email.status).to eq('failed')
        expect(ingested_email.error_message).to include('No parser found')
      end

      it 'creates failure processing log' do
        processor.call
        
        log = ProcessingLog.last
        expect(log.status).to eq('failure')
        expect(log.parser).to eq('Unknown')
        expect(log.error_message).to include('No parser found')
      end
    end

    context 'when processing raises an exception' do
      before do
        allow(processor).to receive(:load_mail).and_raise(StandardError.new('Test error'))
      end

      it 'does not create customer' do
        expect { processor.call }.not_to change { Customer.count }
      end

      it 'marks email as failed' do
        processor.call
        
        ingested_email.reload
        expect(ingested_email.status).to eq('failed')
        expect(ingested_email.error_message).to include('Processing error')
      end

      it 'creates failure processing log with error details' do
        processor.call
        
        log = ProcessingLog.last
        expect(log.status).to eq('failure')
        expect(log.parser).to eq('EmailProcessor')
        expect(log.error_message).to include('Test error')
      end
    end

    context 'when email has no file attached' do
      let(:ingested_email) { create(:ingested_email) }

      it 'handles missing file gracefully' do
        processor.call
        
        ingested_email.reload
        expect(ingested_email.status).to eq('failed')
        expect(ingested_email.error_message).to include('No file attached')
      end
    end
  end
end
