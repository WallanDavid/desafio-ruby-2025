require 'rails_helper'

RSpec.describe ProcessEmailJob, type: :job do
  let(:ingested_email) { create(:ingested_email) }
  let(:job) { described_class.new }

  describe '#perform' do
    it 'calls EmailProcessor with the ingested email id' do
      processor = instance_double(EmailProcessor)
      expect(EmailProcessor).to receive(:new).with(ingested_email.id).and_return(processor)
      expect(processor).to receive(:call)

      job.perform(ingested_email.id)
    end
  end

  describe 'job enqueueing' do
    it 'enqueues the job' do
      expect {
        described_class.perform_later(ingested_email.id)
      }.to have_enqueued_job(described_class).with(ingested_email.id)
    end
  end
end
