FactoryBot.define do
  factory :policy do
    building
    section { :general }
    sequence(:title) { |number| "Policy #{number}" }
    details { "Policy details" }
    note { nil }
    position { 0 }
  end
end
