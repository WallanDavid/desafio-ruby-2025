class UploadsController < ApplicationController
  def new
    @ingested_emails = IngestedEmail.recent.limit(10)
  end

  def create
    unless params[:file].present?
      flash[:alert] = 'Please select a file to upload.'
      redirect_to root_path
      return
    end

    unless params[:file].content_type == 'message/rfc822' || params[:file].original_filename.end_with?('.eml')
      flash[:alert] = 'Please upload a valid .eml file.'
      redirect_to root_path
      return
    end

    begin
      # Read the email content to extract basic info
      mail = Mail.read_from_string(params[:file].read)
      params[:file].rewind

      ingested_email = IngestedEmail.create!(
        sender: mail.from&.first,
        subject: mail.subject,
        status: :queued
      )

      ingested_email.file.attach(params[:file])

      # Enqueue the processing job
      ProcessEmailJob.perform_later(ingested_email.id)

      flash[:notice] = 'Email uploaded successfully and queued for processing.'
    rescue => e
      flash[:alert] = "Error processing email: #{e.message}"
    end

    redirect_to root_path
  end
end
