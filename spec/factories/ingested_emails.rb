FactoryBot.define do
  factory :ingested_email do
    sender { "noreply@fornecedora.com" }
    subject { Faker::Lorem.sentence }
    status { :queued }

    trait :with_supplier_a_sender do
      sender { "noreply@fornecedora.com" }
    end

    trait :with_partner_b_sender do
      sender { "contato@parceirob.com" }
    end

    trait :with_unknown_sender do
      sender { "unknown@example.com" }
    end

    trait :processing do
      status { :processing }
    end

    trait :success do
      status { :success }
    end

    trait :failed do
      status { :failed }
      error_message { "Processing failed" }
    end

    trait :with_file do
      after(:create) do |ingested_email|
        file_content = File.read(Rails.root.join('spec', 'fixtures', 'emails', 'supplier_a_full_1.eml'))
        ingested_email.file.attach(
          io: StringIO.new(file_content),
          filename: 'test.eml',
          content_type: 'message/rfc822'
        )
      end
    end
  end
end
