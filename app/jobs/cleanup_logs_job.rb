class CleanupLogsJob < ApplicationJob
  queue_as :default

  def perform
    retention_days = ENV.fetch('LOG_RETENTION_DAYS', 30).to_i
    Logs::CleanupService.new(days: retention_days).call
  end
end
