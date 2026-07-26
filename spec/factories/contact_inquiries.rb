FactoryBot.define do
  factory :contact_inquiry do
    apartment_listing
    name { "Alex Resident" }
    sequence(:email) { |number| "resident#{number}@example.com" }
    phone { "312-555-0100" }
    message { "I would like to schedule a tour." }
  end
end
