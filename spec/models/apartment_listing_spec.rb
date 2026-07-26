require "rails_helper"

RSpec.describe ApartmentListing, type: :model do
  describe "validations" do
    it "requires a building" do
      listing = build(:apartment_listing, building: nil)

      expect(listing).not_to be_valid
      expect(listing.errors[:building]).to include("must exist")
    end

    %i[unit_number price_cents transaction_type status bedrooms bathrooms].each do |attribute|
      it "requires #{attribute}" do
        listing = build(:apartment_listing, attribute => nil)

        expect(listing).not_to be_valid
        expect(listing.errors[attribute]).to be_present
      end
    end

    it "requires a positive integer price in cents" do
      expect(build(:apartment_listing, price_cents: 1)).to be_valid

      [ 0, -1, 10.5 ].each do |price|
        expect(build(:apartment_listing, price_cents: price)).not_to be_valid
      end
    end

    it "allows zero bedrooms but rejects negative bedrooms" do
      expect(build(:apartment_listing, bedrooms: 0)).to be_valid
      expect(build(:apartment_listing, bedrooms: -0.5)).not_to be_valid
    end

    it "requires bathrooms to be greater than zero" do
      expect(build(:apartment_listing, bathrooms: 0.5)).to be_valid

      [ 0, -0.5 ].each do |bathrooms|
        expect(build(:apartment_listing, bathrooms:)).not_to be_valid
      end
    end
  end

  describe "enums" do
    it "uses the requested string-backed transaction type values" do
      expect(described_class.transaction_types).to eq(
        "rent" => "rent",
        "sale" => "sale"
      )
    end

    it "uses the requested string-backed status values" do
      expect(described_class.statuses).to eq(
        "active" => "active",
        "inactive" => "inactive"
      )
    end
  end

  describe ".currently_available" do
    it "excludes inactive records and orders by position and unit number" do
      building = create(:building)
      later = create(
        :apartment_listing,
        building:,
        unit_number: "300",
        position: 2,
        status: :active
      )
      inactive = create(
        :apartment_listing,
        building:,
        unit_number: "100",
        position: 0,
        status: :inactive
      )
      unit_b = create(
        :apartment_listing,
        building:,
        unit_number: "200-B",
        position: 1,
        status: :active
      )
      unit_a = create(
        :apartment_listing,
        building:,
        unit_number: "200-A",
        position: 1,
        status: :active
      )

      expect(described_class.currently_available).to eq([ unit_a, unit_b, later ])
      expect(described_class.currently_available).not_to include(inactive)
    end
  end

  describe "associations" do
    it "defines its photo attachment" do
      expect(described_class.reflect_on_attachment(:photo)).to be_present
    end

    it "prevents destruction when contact inquiries exist" do
      listing = create(:apartment_listing)
      inquiry = create(:contact_inquiry, apartment_listing: listing)

      expect(listing.destroy).to be(false)
      expect(listing).to be_persisted
      expect(listing.errors[:base]).to be_present
      expect(ContactInquiry.exists?(inquiry.id)).to be(true)
    end
  end
end
