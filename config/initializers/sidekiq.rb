require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  redis_url = Rails.env.test? ? 'redis://localhost:6379/0' : 'redis://redis:6379/0'
  config.redis = { url: ENV.fetch('REDIS_URL', redis_url) }
  
  # Load cron jobs only in non-test environment
  unless Rails.env.test?
    schedule_file = Rails.root.join('config', 'sidekiq.yml')
    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)[:schedule]
    end
  end
end

Sidekiq.configure_client do |config|
  redis_url = Rails.env.test? ? 'redis://localhost:6379/0' : 'redis://redis:6379/0'
  config.redis = { url: ENV.fetch('REDIS_URL', redis_url) }
end
