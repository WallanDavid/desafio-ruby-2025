require 'rails_helper'

RSpec.describe ProcessingLog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:parser) }
    it { should validate_presence_of(:extracted_payload) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(success: 0, failure: 1) }
  end

  describe 'associations' do
    it { should belong_to(:ingested_email) }
  end

  describe 'scopes' do
    let!(:recent_log) { create(:processing_log, created_at: 1.hour.ago) }
    let!(:old_log) { create(:processing_log, created_at: 1.day.ago) }

    describe '.recent' do
      it 'returns logs ordered by created_at desc' do
        expect(ProcessingLog.recent.first).to eq(recent_log)
      end
    end

    describe '.by_parser' do
      let!(:supplier_log) { create(:processing_log, :with_supplier_a_parser) }
      let!(:partner_log) { create(:processing_log, :with_partner_b_parser) }

      it 'filters by parser' do
        expect(ProcessingLog.by_parser('Parsers::SupplierAParser')).to include(supplier_log)
        expect(ProcessingLog.by_parser('Parsers::SupplierAParser')).not_to include(partner_log)
      end
    end

    describe '.by_status' do
      let!(:success_log) { create(:processing_log, status: :success) }
      let!(:failure_log) { create(:processing_log, :failure) }

      it 'filters by status' do
        expect(ProcessingLog.by_status(:success)).to include(success_log)
        expect(ProcessingLog.by_status(:success)).not_to include(failure_log)
      end
    end
  end

  describe '#extracted_data' do
    it 'returns extracted_payload as hash' do
      log = create(:processing_log)
      expect(log.extracted_data).to be_a(Hash)
      expect(log.extracted_data).to eq(log.extracted_payload)
    end

    it 'returns empty hash when extracted_payload is not a hash' do
      log = create(:processing_log, extracted_payload: 'invalid')
      expect(log.extracted_data).to eq({})
    end
  end

  describe '#has_customer_data?' do
    it 'returns true when email is present' do
      log = create(:processing_log, extracted_payload: { email: 'test@example.com' })
      expect(log.has_customer_data?).to be true
    end

    it 'returns true when phone is present' do
      log = create(:processing_log, extracted_payload: { phone: '11999999999' })
      expect(log.has_customer_data?).to be true
    end

    it 'returns false when neither email nor phone is present' do
      log = create(:processing_log, :without_contact_data)
      expect(log.has_customer_data?).to be false
    end
  end
end
