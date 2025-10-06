class Logs::CleanupService
  def initialize(days: 30)
    @days = days
  end

  def call
    cleanup_old_logs
    cleanup_old_emails
  end

  private

  attr_reader :days

  def cleanup_old_logs
    cutoff_date = days.days.ago
    deleted_count = ProcessingLog.where('created_at < ?', cutoff_date).delete_all
    
    Rails.logger.info "Cleaned up #{deleted_count} processing logs older than #{days} days"
    deleted_count
  end

  def cleanup_old_emails
    cutoff_date = days.days.ago
    
    # Find emails that are old and have no processing logs
    old_emails = IngestedEmail
                   .where('created_at < ?', cutoff_date)
                   .left_joins(:processing_logs)
                   .where(processing_logs: { id: nil })
    
    deleted_count = 0
    old_emails.find_each do |email|
      # Delete the attached file first
      email.file.purge if email.file.attached?
      email.destroy
      deleted_count += 1
    end
    
    Rails.logger.info "Cleaned up #{deleted_count} old ingested emails without logs"
    deleted_count
  end
end
