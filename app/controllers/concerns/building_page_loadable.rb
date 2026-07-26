module BuildingPageLoadable
  extend ActiveSupport::Concern

  private

  def load_building_page(scope)
    @building = scope
      .includes(
        :policies,
        cover_image_attachment: :blob,
        active_apartment_listings: { photo_attachment: :blob }
      )
      .take!

    @listings_by_transaction_type = @building.active_apartment_listings.group_by(&:transaction_type)
    @policies_by_section = @building.policies.group_by(&:section)
  end
end
