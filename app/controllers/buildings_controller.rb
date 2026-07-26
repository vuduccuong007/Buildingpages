class BuildingsController < ApplicationController
  def index
    @buildings = Building.ordered
      .with_attached_cover_image
      .with_attached_gallery_images
      .to_a
    @featured_building = @buildings.first
  end

  def show
    @building = Building.find_by!(slug: params[:slug])
  end
end
