Rails.application.configure do
  # Use Sidekiq as the default job queue adapter
  config.active_job.queue_adapter = :sidekiq
end

# Configure ActiveJob for different environments
Rails.application.config.active_job.queue_adapter = :sidekiq unless Rails.env.test?
