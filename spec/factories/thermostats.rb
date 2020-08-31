FactoryBot.define do
  factory :thermostat do
    household_token { SecureRandom.uuid }
    street { Faker::Address.street_name }
    zip_code { Faker::Address.zip_code }
    city { Faker::Address.city  }
    country { Faker::Address.country }
  end
end
