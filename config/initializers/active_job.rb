Rails.application.configure do
  # Use Sidekiq as the default job queue adapter (except in test environment)
  config.active_job.queue_adapter = Rails.env.test? ? :test : :sidekiq
end
