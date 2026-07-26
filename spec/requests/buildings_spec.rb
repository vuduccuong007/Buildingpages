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

  describe "GET /buildings/autocomplete" do
    let(:results) { response.parsed_body }

    it "returns no results for a query shorter than two characters" do
      create(:building, name: "Park House")

      get autocomplete_buildings_path, params: { q: " P " }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end

    it "searches by building name" do
      building = create(:building, name: "Park House")
      create(:building, name: "River House")

      get autocomplete_buildings_path, params: { q: "Park" }, as: :json

      expect(results.pluck("name")).to eq([ building.name ])
    end

    it "searches by neighborhood" do
      building = create(:building, neighborhood: "Lincoln Park")
      create(:building, neighborhood: "River North")

      get autocomplete_buildings_path, params: { q: "Lincoln" }, as: :json

      expect(results.pluck("name")).to eq([ building.name ])
    end

    it "searches by street address" do
      building = create(:building, street_address: "742 Evergreen Terrace")
      create(:building, street_address: "123 Main Street")

      get autocomplete_buildings_path, params: { q: "Evergreen" }, as: :json

      expect(results.pluck("name")).to eq([ building.name ])
    end

    it "searches by city" do
      building = create(:building, city: "Evanston")
      create(:building, city: "Chicago")

      get autocomplete_buildings_path, params: { q: "Evanston" }, as: :json

      expect(results.pluck("name")).to eq([ building.name ])
    end

    it "searches case-insensitively" do
      building = create(:building, name: "McKinley Court")

      get autocomplete_buildings_path, params: { q: "mckinley" }, as: :json

      expect(results.pluck("name")).to eq([ building.name ])
    end

    it "treats SQL wildcard characters as literal characters" do
      percent_building = create(:building, name: "100% Plaza")
      create(:building, name: "1000 Plaza")
      underscore_building = create(:building, name: "Tower_One")
      create(:building, name: "TowerXOne")

      get autocomplete_buildings_path, params: { q: "100%" }, as: :json

      expect(response.parsed_body.pluck("name")).to eq([ percent_building.name ])

      get autocomplete_buildings_path, params: { q: "Tower_" }, as: :json

      expect(response.parsed_body.pluck("name")).to eq([ underscore_building.name ])
    end

    it "does not interpret SQL injection payloads" do
      create(:building, name: "Park House")

      get autocomplete_buildings_path, params: { q: "' OR 1=1 --" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(results).to eq([])
    end

    it "orders results by position and name" do
      third = create(:building, name: "Search Alpha", position: 2)
      second = create(:building, name: "Search Charlie", position: 1)
      first = create(:building, name: "Search Bravo", position: 1)

      get autocomplete_buildings_path, params: { q: "Search" }, as: :json

      expect(results.pluck("name")).to eq([ first.name, second.name, third.name ])
    end

    it "limits the response to eight buildings" do
      create_list(:building, 9, neighborhood: "Search District")

      get autocomplete_buildings_path, params: { q: "Search District" }, as: :json

      expect(results.length).to eq(8)
    end

    it "returns only public autocomplete fields" do
      building = create(
        :building,
        name: "Park House",
        neighborhood: "Lincoln Park",
        street_address: "500 Park Avenue"
      )

      get autocomplete_buildings_path, params: { q: "Park" }, as: :json

      expect(results).to contain_exactly(
        {
          "name" => building.name,
          "neighborhood" => building.neighborhood,
          "full_address" => building.full_address,
          "url" => building_path(building)
        }
      )
    end

    it "returns an empty array when no buildings match" do
      create(:building, name: "Park House")

      get autocomplete_buildings_path, params: { q: "No such building" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(results).to eq([])
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
