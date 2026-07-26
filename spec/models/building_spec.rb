require "rails_helper"

RSpec.describe Building, type: :model do
  describe "validations" do
    %i[name street_address city].each do |attribute|
      it "requires #{attribute}" do
        building = build(:building, attribute => nil)

        expect(building).not_to be_valid
        expect(building.errors[attribute]).to include("can't be blank")
      end
    end

    it "requires a slug when one cannot be generated" do
      building = build(:building, name: nil, slug: nil)

      expect(building).not_to be_valid
      expect(building.errors[:slug]).to include("can't be blank")
    end

    it "requires unique slugs" do
      create(:building, slug: "the-pearl")
      duplicate = build(:building, slug: "the-pearl")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include("has already been taken")
    end

    it "backs slug uniqueness with a unique database index" do
      index = described_class.connection.indexes(:buildings).find do |candidate|
        candidate.columns == [ "slug" ]
      end

      expect(index.unique).to be(true)
    end
  end

  describe "slugging" do
    it "generates a parameterized slug before validation when blank" do
      building = build(:building, name: "The Pearl at Lake Shore", slug: nil)

      building.validate

      expect(building.slug).to eq("the-pearl-at-lake-shore")
    end

    it "preserves an explicitly supplied slug" do
      building = build(:building, name: "The Pearl", slug: "custom-address")

      building.validate

      expect(building.slug).to eq("custom-address")
    end

    it "uses the slug as the URL parameter" do
      building = build(:building, slug: "the-pearl")

      expect(building.to_param).to eq("the-pearl")
    end
  end

  describe "#full_address" do
    it "joins the populated address components" do
      building = build(
        :building,
        street_address: "500 Lake Shore Drive",
        city: "Chicago",
        state: "IL",
        postal_code: "60611"
      )

      expect(building.full_address)
        .to eq("500 Lake Shore Drive, Chicago, IL, 60611")
    end

    it "omits blank optional address components" do
      building = build(:building, state: nil, postal_code: "")

      expect(building.full_address).to eq("123 Main Street, Chicago")
    end
  end

  describe ".ordered" do
    it "orders by position and then name" do
      second = create(:building, name: "Beta", position: 2)
      alpha = create(:building, name: "Alpha", position: 1)
      zulu = create(:building, name: "Zulu", position: 1)

      expect(described_class.ordered).to eq([ alpha, zulu, second ])
    end
  end

  describe "associations" do
    it "defines the requested Active Storage attachments" do
      expect(described_class.reflect_on_attachment(:cover_image)).to be_present
      expect(described_class.reflect_on_all_attachments.map(&:name))
        .to include(:gallery_images)
    end

    it "destroys its policies and apartment listings" do
      building = create(:building)
      policy = create(:policy, building:)
      listing = create(:apartment_listing, building:)

      building.destroy!

      expect(Policy.exists?(policy.id)).to be(false)
      expect(ApartmentListing.exists?(listing.id)).to be(false)
    end
  end
end
