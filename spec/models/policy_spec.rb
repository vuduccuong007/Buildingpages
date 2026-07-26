require "rails_helper"

RSpec.describe Policy, type: :model do
  describe "validations" do
    it "requires a building" do
      policy = build(:policy, building: nil)

      expect(policy).not_to be_valid
      expect(policy.errors[:building]).to include("must exist")
    end

    %i[section title].each do |attribute|
      it "requires #{attribute}" do
        policy = build(:policy, attribute => nil)

        expect(policy).not_to be_valid
        expect(policy.errors[attribute]).to be_present
      end
    end
  end

  describe "sections" do
    it "uses the requested string-backed enum values" do
      expect(described_class.sections).to eq(
        "general" => "general",
        "additional_information" => "additional_information"
      )
    end
  end

  describe ".ordered" do
    it "orders by position" do
      last = create(:policy, position: 3)
      first = create(:policy, position: 1)
      second = create(:policy, position: 2)

      expect(described_class.ordered).to eq([ first, second, last ])
    end

    it "is opt-in rather than a default scope" do
      expect(described_class.default_scopes).to be_empty
    end
  end
end
