require 'rails_helper'

RSpec.describe "ProcessingLogs", type: :request do
  describe "GET /processing_logs" do
    let!(:success_log) { create(:processing_log, :with_supplier_a_parser, status: :success) }
    let!(:failure_log) { create(:processing_log, :with_partner_b_parser, :failure) }

    it "returns http success" do
      get processing_logs_path
      expect(response).to have_http_status(:success)
    end

    it "displays all processing logs" do
      get processing_logs_path
      
      expect(response.body).to include("Processing Logs")
      expect(response.body).to include("SupplierAParser")
      expect(response.body).to include("PartnerBParser")
    end

    context "with status filter" do
      it "filters by success status" do
        get processing_logs_path, params: { status: 'success' }
        
        expect(response.body).to include("SupplierAParser")
        expect(response.body).not_to include("PartnerBParser")
      end

      it "filters by failure status" do
        get processing_logs_path, params: { status: 'failure' }
        
        expect(response.body).to include("PartnerBParser")
        expect(response.body).not_to include("SupplierAParser")
      end
    end

    context "with parser filter" do
      it "filters by parser" do
        get processing_logs_path, params: { parser: 'Parsers::SupplierAParser' }
        
        expect(response.body).to include("SupplierAParser")
        expect(response.body).not_to include("PartnerBParser")
      end
    end

    context "with no logs" do
      before { ProcessingLog.delete_all }

      it "shows empty state" do
        get processing_logs_path
        
        expect(response.body).to include("No processing logs found")
        expect(response.body).to include("Upload some .eml files")
      end
    end
  end
end
