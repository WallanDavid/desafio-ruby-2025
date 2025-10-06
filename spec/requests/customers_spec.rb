require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe "GET /customers" do
    let!(:customer1) { create(:customer, email: 'john@example.com', phone: '11999999999') }
    let!(:customer2) { create(:customer, email: 'jane@test.com', phone: '11888888888') }

    it "returns http success" do
      get customers_path
      expect(response).to have_http_status(:success)
    end

    it "displays all customers" do
      get customers_path
      
      expect(response.body).to include("Customers")
      expect(response.body).to include("john@example.com")
      expect(response.body).to include("jane@test.com")
    end

    context "with email filter" do
      it "filters by email" do
        get customers_path, params: { email: 'john' }
        
        expect(response.body).to include("john@example.com")
        expect(response.body).not_to include("jane@test.com")
      end
    end

    context "with phone filter" do
      it "filters by phone" do
        get customers_path, params: { phone: '9999' }
        
        expect(response.body).to include("11999999999")
        expect(response.body).not_to include("11888888888")
      end
    end

    context "with no customers" do
      before { Customer.delete_all }

      it "shows empty state" do
        get customers_path
        
        expect(response.body).to include("No customers found")
        expect(response.body).to include("Upload some .eml files")
      end
    end
  end
end
