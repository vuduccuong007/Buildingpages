FactoryBot.define do
  factory :building do
    sequence(:name) { |number| "Building #{number}" }
    slug { name.to_s.parameterize }
    street_address { "123 Main Street" }
    city { "Chicago" }
    state { "IL" }
    postal_code { "60601" }
    neighborhood { "The Loop" }
    ownership_type { "Condominium" }
    description { "A centrally located residential building." }
    latitude { 41.881832 }
    longitude { -87.623177 }
    position { 0 }
  end
end
