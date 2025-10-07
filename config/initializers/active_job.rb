Rails.application.configure do
  # Use Sidekiq as the default job queue adapter
  config.active_job.queue_adapter = :sidekiq
end
