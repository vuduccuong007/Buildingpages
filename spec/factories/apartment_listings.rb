FactoryBot.define do
  factory :apartment_listing do
    building
    sequence(:unit_number) { |number| "Unit #{number}" }
    price_cents { 250_000 }
    transaction_type { :rent }
    status { :active }
    bedrooms { 1 }
    bathrooms { 1 }
    available_from { Date.current }
    position { 0 }
  end
end
