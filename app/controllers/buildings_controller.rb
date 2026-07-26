class BuildingsController < ApplicationController
  include BuildingPageLoadable

  def index
    @buildings = Building.ordered
      .with_attached_cover_image
      .with_attached_gallery_images
      .to_a
    @featured_building = @buildings.first
  end

  def show
    @contact_inquiry = ContactInquiry.new
    load_building_page(Building.where(slug: params[:slug]))
  end
end
