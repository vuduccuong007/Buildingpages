require "rails_helper"

RSpec.describe ContactInquiry, type: :model do
  describe "validations" do
    it "requires an apartment listing" do
      inquiry = build(:contact_inquiry, apartment_listing: nil)

      expect(inquiry).not_to be_valid
      expect(inquiry.errors[:apartment_listing]).to include("must exist")
    end

    %i[name email message].each do |attribute|
      it "requires #{attribute}" do
        inquiry = build(:contact_inquiry, attribute => nil)

        expect(inquiry).not_to be_valid
        expect(inquiry.errors[attribute]).to be_present
      end
    end

    it "accepts a valid email address" do
      inquiry = build(:contact_inquiry, email: "resident+tour@example.com")

      expect(inquiry).to be_valid
    end

    it "rejects invalid email addresses" do
      [ "not-an-email", "resident@", "@example.com" ].each do |email|
        inquiry = build(:contact_inquiry, email:)

        expect(inquiry).not_to be_valid
        expect(inquiry.errors[:email]).to include("is invalid")
      end
    end
  end
end
