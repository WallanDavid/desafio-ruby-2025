class ProcessingLogsController < ApplicationController
  def index
    @processing_logs = ProcessingLog.includes(:ingested_email).recent
    
    if params[:status].present?
      @processing_logs = @processing_logs.by_status(params[:status])
    end
    
    if params[:parser].present?
      @processing_logs = @processing_logs.by_parser(params[:parser])
    end
    
    @processing_logs = @processing_logs.page(params[:page])
  end
end
