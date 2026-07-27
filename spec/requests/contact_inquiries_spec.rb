require "rails_helper"

RSpec.describe "Contact inquiries", type: :request do
  describe "POST /contact_inquiries" do
    before { ActionMailer::Base.deliveries.clear }

    let(:building) { create(:building, slug: "one-sutton-place") }
    let(:listing) do
      create(
        :apartment_listing,
        building:,
        unit_number: "12A",
        status: :active
      )
    end
    let(:valid_attributes) do
      {
        name: "Alex Resident",
        email: "alex@example.com",
        phone: "312-555-0100",
        message: "I would like to schedule a visit."
      }
    end

    it "persists a valid inquiry for the selected listing" do
      expect do
        post contact_inquiries_path,
             params: {
               apartment_listing_id: listing.id,
               contact_inquiry: valid_attributes
             }
      end.to change(ContactInquiry, :count).by(1)
        .and change { ActionMailer::Base.deliveries.count }.by(1)

      inquiry = ContactInquiry.order(:created_at).last

      expect(inquiry.apartment_listing).to eq(listing)
      expect(inquiry).to have_attributes(valid_attributes)
      expect(ActionMailer::Base.deliveries.last.to).to eq(
        [ ENV.fetch("CONTACT_RECIPIENT_EMAIL", "leasing@example.test") ]
      )
    end

    it "redirects to the selected listing's building slug and preserves the listing anchor" do
      other_building = create(:building)

      post contact_inquiries_path,
           params: {
             building_id: other_building.id,
             apartment_listing_id: listing.id,
             contact_inquiry: valid_attributes
           }

      expect(response).to redirect_to(
        "/buildings/one-sutton-place#apartment-listing-#{listing.id}"
      )
      expect(flash[:notice]).to include("unit 12A")
    end

    it "returns 422 without persisting an invalid inquiry" do
      expect do
        post contact_inquiries_path,
             params: {
               apartment_listing_id: listing.id,
               contact_inquiry: valid_attributes.merge(name: "", email: "not-an-email", message: "")
             }
      end.not_to change(ContactInquiry, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it "preserves submitted values and reopens the dialog after validation failure" do
      submitted_attributes = valid_attributes.merge(
        name: "Alex & Jordan",
        email: "invalid",
        phone: "773-555-0199",
        message: "Please call after 6."
      )

      post contact_inquiries_path,
           params: {
             apartment_listing_id: listing.id,
             contact_inquiry: submitted_attributes
           }

      page = Capybara.string(response.body)

      expect(page).to have_field("Name", with: "Alex & Jordan", visible: :all)
      expect(page).to have_field("Email", with: "invalid", visible: :all)
      expect(page).to have_field("Phone (optional)", with: "773-555-0199", visible: :all)
      expect(page).to have_field("Message", with: "Please call after 6.", visible: :all)
      expect(page).to have_css(
        "[data-controller='contact-inquiry'][data-contact-inquiry-open-value='true']"
      )
      expect(page).to have_css("[role='alert']", text: "Email is invalid")
      expect(page).to have_css("#contact-inquiry-email-error", text: "Email is invalid")
      expect(page.find_field("Email", visible: :all)[:"aria-invalid"]).to eq("true")
      expect(page.find_field("Email", visible: :all)[:"aria-describedby"]).to eq(
        "contact-inquiry-email-error"
      )
      expect(page).to have_text("12A")
    end

    it "redirects an inactive listing to the 404 page" do
      inactive_listing = create(:apartment_listing, building:, status: :inactive)

      expect do
        post contact_inquiries_path,
             params: {
               apartment_listing_id: inactive_listing.id,
               contact_inquiry: valid_attributes
             }
      end.not_to change(ContactInquiry, :count)

      expect(response).to redirect_to("/404.html")
    end

    it "redirects an unknown listing to the 404 page" do
      expect do
        post contact_inquiries_path,
             params: {
               apartment_listing_id: 0,
               contact_inquiry: valid_attributes
             }
      end.not_to change(ContactInquiry, :count)

      expect(response).to redirect_to("/404.html")
    end
  end
end
