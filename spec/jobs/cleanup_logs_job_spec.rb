require 'rails_helper'

RSpec.describe CleanupLogsJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) { described_class.new }

  describe '#perform' do
    it 'calls Logs::CleanupService with default retention days' do
      service = instance_double(Logs::CleanupService)
      expect(Logs::CleanupService).to receive(:new).with(days: 30).and_return(service)
      expect(service).to receive(:call)

      job.perform
    end

    it 'uses custom retention days from environment' do
      allow(ENV).to receive(:fetch).with('LOG_RETENTION_DAYS', 30).and_return(7)
      
      service = instance_double(Logs::CleanupService)
      expect(Logs::CleanupService).to receive(:new).with(days: 7).and_return(service)
      expect(service).to receive(:call)

      job.perform
    end
  end

  describe 'job enqueueing' do
    it 'enqueues the job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class)
    end
  end
end
