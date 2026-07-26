require "rails_helper"

RSpec.describe "Buildings", type: :request do
  describe "GET /buildings" do
    it "returns a successful response" do
      get buildings_path

      expect(response).to have_http_status(:ok)
    end

    it "renders building names and neighborhoods in display order" do
      second = create(:building, name: "York Place", neighborhood: "Brooklyn Heights", position: 2)
      first = create(:building, name: "One Sutton Place", neighborhood: "Sutton Place", position: 1)

      get buildings_path

      expect(response.body).to include(first.name, first.neighborhood)
      expect(response.body).to include(second.name, second.neighborhood)
      expect(response.body.index(first.name)).to be < response.body.index(second.name)
    end

    it "links each building with its slug" do
      building = create(:building, name: "One Sutton Place", slug: "one-sutton-place")

      get buildings_path

      expect(response.body).to include(%(href="/buildings/one-sutton-place"))
    end

    it "renders an empty portfolio state" do
      get buildings_path

      expect(response.body).to include("No buildings are currently available")
      expect(response.body).to include("Please check back soon")
    end

    it "does not render inactive apartment listing information" do
      building = create(:building)
      create(
        :apartment_listing,
        building:,
        status: :inactive,
        unit_number: "INACTIVE-14A",
        price_cents: 9_876_00
      )

      get buildings_path

      expect(response.body).not_to include("INACTIVE-14A")
      expect(response.body).not_to include("9876")
    end
  end

  describe "GET /buildings/:slug" do
    it "finds a building by slug" do
      building = create(:building, name: "One Sutton Place", slug: "one-sutton-place")

      get "/buildings/one-sutton-place"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("One Sutton Place")
    end

    it "renders the building name, address, description, ownership type, and map" do
      building = create(
        :building,
        name: "One Sutton Place",
        street_address: "18 Sutton Place South",
        city: "New York",
        state: "NY",
        postal_code: "10022",
        ownership_type: "Condominium",
        description: "A quiet East River residence.",
        latitude: 40.756436,
        longitude: -73.961532
      )

      get building_path(building)

      page = Capybara.string(response.body)
      map = page.find("iframe[title='One Sutton Place map']")

      expect(page).to have_text("One Sutton Place")
      expect(page).to have_text("18 Sutton Place South, New York, NY, 10022")
      expect(page).to have_text("A quiet East River residence.")
      expect(page).to have_text("Condominium")
      expect(map[:src]).to start_with("https://www.openstreetmap.org/export/embed.html?")
      expect(map[:src]).to include("marker=40.756436%2C-73.961532")
    end

    it "renders active rentals in the rental section" do
      building = create(:building)
      listing = create(
        :apartment_listing,
        building:,
        transaction_type: :rent,
        unit_number: "RENT-4B",
        price_cents: 425_000,
        bedrooms: 0,
        bathrooms: 1.5
      )

      get building_path(building)

      page = Capybara.string(response.body)
      rental_section = page.find("section[aria-labelledby='rental-listings-heading']")

      expect(rental_section).to have_text("Apartments for Rent")
      expect(rental_section).to have_text("RENT-4B")
      expect(rental_section).to have_text("$4,250")
      expect(rental_section).to have_text("Monthly")
      expect(rental_section).to have_text("Studio")
      expect(rental_section.text).to match(/1\.5\s+Bathrooms/)
      expect(rental_section).to have_button("Schedule a Visit", disabled: false)
      expect(rental_section).to have_link("Use inquiry form", href: "#contact-inquiry-form")
      expect(rental_section).to have_css(
        "button[data-contact-inquiry-listing-id-param='#{listing.id}']"
      )
    end

    it "renders active sales in the sale section without a monthly label" do
      building = create(:building)
      create(
        :apartment_listing,
        building:,
        transaction_type: :sale,
        unit_number: "SALE-12A",
        price_cents: 125_000_000
      )

      get building_path(building)

      page = Capybara.string(response.body)
      sale_section = page.find("section[aria-labelledby='sale-listings-heading']")

      expect(sale_section).to have_text("Apartments for Sale")
      expect(sale_section).to have_text("SALE-12A")
      expect(sale_section).to have_text("$1,250,000")
      expect(sale_section).not_to have_text("Monthly")
    end

    it "excludes inactive listings" do
      building = create(:building)
      create(
        :apartment_listing,
        building:,
        transaction_type: :rent,
        status: :inactive,
        unit_number: "INACTIVE-14A",
        price_cents: 987_600
      )

      get building_path(building)

      expect(response.body).not_to include("INACTIVE-14A")
      expect(response.body).not_to include("$9,876")
      expect(response.body).not_to include("Apartments for Rent")
      expect(response.body).to include("There are no active apartment listings at this time.")
    end

    it "groups policies by section and follows position order" do
      building = create(:building)
      create(
        :policy,
        building:,
        section: :general,
        title: "Second General",
        position: 2
      )
      create(
        :policy,
        building:,
        section: :additional_information,
        title: "Additional Detail",
        position: 1
      )
      create(
        :policy,
        building:,
        section: :general,
        title: "First General",
        position: 1
      )

      get building_path(building)

      page = Capybara.string(response.body)
      sections = page.all(".policy-section")
      general = sections.find { |section| section.has_text?("General Policies") }
      additional = sections.find { |section| section.has_text?("Additional Building Info") }

      expect(general).to have_text("First General")
      expect(general).to have_text("Second General")
      expect(general.text.index("First General")).to be < general.text.index("Second General")
      expect(general).not_to have_text("Additional Detail")
      expect(additional).to have_text("Additional Detail")
      expect(additional).not_to have_text("First General")
    end

    it "returns 404 for an unknown slug" do
      get "/buildings/not-a-building"

      expect(response).to have_http_status(:not_found)
    end

    it "renders one progressively enhanced inquiry dialog for all listings" do
      building = create(:building)
      create_list(:apartment_listing, 2, building:)

      get building_path(building)

      page = Capybara.string(response.body)

      expect(page).to have_css("dialog#contact-inquiry-form", count: 1)
      expect(page).to have_css("dialog#contact-inquiry-form[open]")
      expect(page).to have_css("noscript select[name='apartment_listing_id']")
      expect(page).to have_field("Name", visible: :all)
      expect(page).to have_field("Email", visible: :all)
      expect(page).to have_field("Phone (optional)", visible: :all)
      expect(page).to have_field("Message", visible: :all)
    end

    it "renders a visible map fallback when coordinates are missing" do
      building = create(:building, latitude: nil, longitude: nil)

      get building_path(building)

      page = Capybara.string(response.body)

      expect(page).to have_text("Map unavailable for this building.")
      expect(page).to have_css(".building-map__fallback")
      expect(page).not_to have_css(".building-map iframe")
    end
  end
end
