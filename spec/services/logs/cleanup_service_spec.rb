require 'rails_helper'

RSpec.describe Logs::CleanupService do
  let(:service) { described_class.new(days: 30) }

  describe '#call' do
    let!(:old_log) { create(:processing_log, created_at: 35.days.ago) }
    let!(:recent_log) { create(:processing_log, created_at: 10.days.ago) }
    let!(:old_email) { create(:ingested_email, created_at: 35.days.ago) }
    let!(:recent_email) { create(:ingested_email, created_at: 10.days.ago) }

    it 'deletes old processing logs' do
      expect { service.call }.to change { ProcessingLog.count }.by(-1)
      expect(ProcessingLog.exists?(old_log.id)).to be false
      expect(ProcessingLog.exists?(recent_log.id)).to be true
    end

    it 'deletes old emails without processing logs' do
      expect { service.call }.to change { IngestedEmail.count }.by(-1)
      expect(IngestedEmail.exists?(old_email.id)).to be false
      expect(IngestedEmail.exists?(recent_email.id)).to be true
    end

    it 'does not delete old emails that have processing logs' do
      create(:processing_log, ingested_email: old_email, created_at: 5.days.ago)
      
      expect { service.call }.not_to change { IngestedEmail.count }
      expect(IngestedEmail.exists?(old_email.id)).to be true
    end

    it 'respects custom retention period' do
      custom_service = described_class.new(days: 5)
      old_log.update!(created_at: 10.days.ago)
      
      expect { custom_service.call }.to change { ProcessingLog.count }.by(-1)
      expect(ProcessingLog.exists?(old_log.id)).to be false
    end

    it 'logs cleanup information' do
      expect(Rails.logger).to receive(:info).with(/Cleaned up 1 processing logs/)
      expect(Rails.logger).to receive(:info).with(/Cleaned up 1 old ingested emails/)
      
      service.call
    end
  end
end
