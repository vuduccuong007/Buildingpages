require "rails_helper"

RSpec.describe ContactInquiryMailer, type: :mailer do
  describe "#new_inquiry" do
    let(:building) do
      create(
        :building,
        name: "One Sutton Place",
        street_address: "100 Sutton Place",
        city: "Chicago",
        state: "IL",
        postal_code: "60601"
      )
    end
    let(:listing) do
      create(
        :apartment_listing,
        building:,
        unit_number: "12A",
        transaction_type: :rent,
        price_cents: 245_000
      )
    end
    let(:inquiry) do
      create(
        :contact_inquiry,
        apartment_listing: listing,
        name: "Alex Resident",
        email: "alex@example.com",
        phone: "312-555-0100",
        message: "I would like to schedule a visit."
      )
    end
    let(:mail) { described_class.with(inquiry:).new_inquiry }

    it "uses the configured recipient, sender, and listing-specific subject" do
      expect(ActionMailer::Base.delivery_method).to eq(:test)
      expect(mail.to).to eq([ ENV.fetch("CONTACT_RECIPIENT_EMAIL", "leasing@example.test") ])
      expect(mail.from).to eq([ ENV.fetch("MAILER_FROM", "building-pages@example.test") ])
      expect(mail.subject).to eq("Apartment inquiry: One Sutton Place, unit 12A")
    end

    it "renders all inquiry details in the HTML body" do
      body = Capybara.string(mail.html_part.body.decoded)

      expect(body).to have_text("One Sutton Place")
      expect(body).to have_text("100 Sutton Place, Chicago, IL, 60601")
      expect(body).to have_text("12A")
      expect(body).to have_text("Rent")
      expect(body).to have_text("$2,450")
      expect(body).to have_text("Alex Resident")
      expect(body).to have_link("alex@example.com", href: "mailto:alex@example.com")
      expect(body).to have_text("312-555-0100")
      expect(body).to have_text("I would like to schedule a visit.")
    end

    it "renders all inquiry details in the text body" do
      body = mail.text_part.body.decoded

      expect(body).to include("Building: One Sutton Place")
      expect(body).to include("Address: 100 Sutton Place, Chicago, IL, 60601")
      expect(body).to include("Unit: 12A")
      expect(body).to include("Transaction type: Rent")
      expect(body).to include("Price: $2,450")
      expect(body).to include("Name: Alex Resident")
      expect(body).to include("Email: alex@example.com")
      expect(body).to include("Phone: 312-555-0100")
      expect(body).to include("I would like to schedule a visit.")
    end
  end
end
