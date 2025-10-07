require 'rails_helper'

RSpec.describe "Uploads", type: :request do
  include ActiveJob::TestHelper
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "displays recent uploaded emails" do
      create_list(:ingested_email, 3)
      
      get root_path
      
      expect(response.body).to include("Recent Uploads")
      expect(response.body).to include("Upload Email (.eml)")
    end
  end

  describe "POST /uploads" do
    let(:valid_eml_content) do
      <<~EML
        From: noreply@fornecedora.com
        To: customer@example.com
        Subject: Test Email
        
        Nome: João Silva
        Email: joao@example.com
        Telefone: (11) 99999-9999
        Código do Produto: PROD-123
      EML
    end

    context "with valid .eml file" do
      let(:file) { fixture_file_upload('emails/supplier_a_full_1.eml', 'message/rfc822') }

      it "creates ingested email and redirects" do
        expect {
          post uploads_path, params: { file: file }
        }.to change { IngestedEmail.count }.by(1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Email uploaded successfully")
      end

      it "enqueues processing job" do
        expect {
          post uploads_path, params: { file: file }
        }.to have_enqueued_job(ProcessEmailJob)
      end
    end

    context "without file" do
      it "shows error and redirects" do
        post uploads_path, params: {}
        
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Please select a file")
      end
    end

    context "with invalid file type" do
      let(:file) { fixture_file_upload('emails/invalid.txt', 'text/plain') }

      it "shows error and redirects" do
        post uploads_path, params: { file: file }
        
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Please upload a valid .eml file")
      end
    end
  end
end
