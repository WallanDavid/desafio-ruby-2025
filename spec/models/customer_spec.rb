require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email).on(:create) }
    it { should validate_presence_of(:phone).on(:create) }
    
    it 'validates email format when present' do
      customer = build(:customer, email: 'invalid-email')
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include('is invalid')
    end

    it 'allows valid email format' do
      customer = build(:customer, email: 'test@example.com')
      expect(customer).to be_valid
    end

    it 'requires at least email or phone' do
      customer = build(:customer, email: nil, phone: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("can't be blank")
      expect(customer.errors[:phone]).to include("can't be blank")
    end

    it 'is valid with email only' do
      customer = build(:customer, :with_email_only)
      expect(customer).to be_valid
    end

    it 'is valid with phone only' do
      customer = build(:customer, :with_phone_only)
      expect(customer).to be_valid
    end
  end

  describe 'scopes' do
    let!(:customer1) { create(:customer, email: 'john@example.com', phone: '11999999999') }
    let!(:customer2) { create(:customer, email: 'jane@test.com', phone: '11888888888') }

    describe '.by_email' do
      it 'filters by email' do
        expect(Customer.by_email('john')).to include(customer1)
        expect(Customer.by_email('john')).not_to include(customer2)
      end
    end

    describe '.by_phone' do
      it 'filters by phone' do
        expect(Customer.by_phone('9999')).to include(customer1)
        expect(Customer.by_phone('9999')).not_to include(customer2)
      end
    end
  end

  describe '#contact_info' do
    it 'returns email and phone joined' do
      customer = build(:customer, email: 'test@example.com', phone: '11999999999')
      expect(customer.contact_info).to eq('test@example.com | 11999999999')
    end

    it 'returns only email when phone is nil' do
      customer = build(:customer, email: 'test@example.com', phone: nil)
      expect(customer.contact_info).to eq('test@example.com')
    end

    it 'returns only phone when email is nil' do
      customer = build(:customer, email: nil, phone: '11999999999')
      expect(customer.contact_info).to eq('11999999999')
    end
  end
end
