FactoryBot.define do
  factory :processing_log do
    association :ingested_email
    parser { "Parsers::SupplierAParser" }
    status { :success }
    extracted_payload do
      {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        phone: "+55#{Faker::Number.number(digits: 2)}9#{Faker::Number.number(digits: 8)}",
        product_code: "PROD-#{Faker::Alphanumeric.alpha(number: 3).upcase}#{Faker::Number.number(digits: 3)}",
        subject: Faker::Lorem.sentence
      }
    end

    trait :failure do
      status { :failure }
      extracted_payload { {} }
      error_message { "Processing failed" }
    end

    trait :with_supplier_a_parser do
      parser { "Parsers::SupplierAParser" }
    end

    trait :with_partner_b_parser do
      parser { "Parsers::PartnerBParser" }
    end

    trait :without_contact_data do
      extracted_payload do
        {
          name: Faker::Name.name,
          email: nil,
          phone: nil,
          product_code: "PROD-123",
          subject: Faker::Lorem.sentence
        }
      end
    end
  end
end
