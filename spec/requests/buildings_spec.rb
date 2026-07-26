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

      get building_path(building)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("One Sutton Place")
    end
  end
end
