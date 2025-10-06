module ApplicationHelper
  def status_badge_color(status)
    case status.to_s
    when 'queued'
      'secondary'
    when 'processing'
      'warning'
    when 'success'
      'success'
    when 'failed'
      'danger'
    else
      'light'
    end
  end
end
