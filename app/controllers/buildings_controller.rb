class BuildingsController < ApplicationController
  def index
    @buildings = Building.ordered
      .with_attached_cover_image
      .with_attached_gallery_images
      .to_a
    @featured_building = @buildings.first
  end

  def show
    @building = Building
      .includes(
        :policies,
        cover_image_attachment: :blob,
        active_apartment_listings: { photo_attachment: :blob }
      )
      .find_by!(slug: params[:slug])

    @listings_by_transaction_type = @building.active_apartment_listings.group_by(&:transaction_type)
    @policies_by_section = @building.policies.group_by(&:section)
  end
end
