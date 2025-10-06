class ProcessEmailJob < ApplicationJob
  queue_as :default

  def perform(ingested_email_id)
    EmailProcessor.new(ingested_email_id).call
  end
end
