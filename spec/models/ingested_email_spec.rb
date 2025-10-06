require 'rails_helper'

RSpec.describe IngestedEmail, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:sender) }
    it { should validate_presence_of(:subject) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(queued: 0, processing: 1, success: 2, failed: 3) }
  end

  describe 'associations' do
    it { should have_many(:processing_logs).dependent(:destroy) }
    it { should have_one_attached(:file) }
  end

  describe 'scopes' do
    let!(:recent_email) { create(:ingested_email, created_at: 1.hour.ago) }
    let!(:old_email) { create(:ingested_email, created_at: 1.day.ago) }

    describe '.recent' do
      it 'returns emails ordered by created_at desc' do
        expect(IngestedEmail.recent.first).to eq(recent_email)
      end
    end

    describe '.by_status' do
      let!(:success_email) { create(:ingested_email, :success) }
      let!(:failed_email) { create(:ingested_email, :failed) }

      it 'filters by status' do
        expect(IngestedEmail.by_status(:success)).to include(success_email)
        expect(IngestedEmail.by_status(:success)).not_to include(failed_email)
      end
    end
  end

  describe '#file_content' do
    let(:ingested_email) { create(:ingested_email) }

    it 'returns nil when no file is attached' do
      expect(ingested_email.file_content).to be_nil
    end

    it 'returns file content when file is attached' do
      ingested_email.file.attach(
        io: StringIO.new('test content'),
        filename: 'test.eml',
        content_type: 'message/rfc822'
      )
      expect(ingested_email.file_content).to eq('test content')
    end
  end

  describe '#processing_duration' do
    let(:ingested_email) { create(:ingested_email, :success) }

    it 'returns nil when not processed' do
      unprocessed = create(:ingested_email)
      expect(unprocessed.processing_duration).to be_nil
    end

    it 'returns processing duration when processed' do
      log = create(:processing_log, ingested_email: ingested_email, created_at: 1.hour.ago)
      ingested_email.update!(created_at: 2.hours.ago)
      
      expect(ingested_email.processing_duration).to be_within(1.second).of(1.hour)
    end
  end
end
