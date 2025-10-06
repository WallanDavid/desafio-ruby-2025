FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { "+55#{Faker::Number.number(digits: 2)}9#{Faker::Number.number(digits: 8)}" }
    product_code { "PROD-#{Faker::Alphanumeric.alpha(number: 3).upcase}#{Faker::Number.number(digits: 3)}" }
    subject { Faker::Lorem.sentence }
  end

  trait :with_email_only do
    phone { nil }
  end

  trait :with_phone_only do
    email { nil }
  end

  trait :without_contact do
    email { nil }
    phone { nil }
  end
end
