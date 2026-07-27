class BuildingsController < ApplicationController
  include BuildingPageLoadable

  BUILDINGS_PER_PAGE = 6

  def index
    page = [ params.fetch(:page, 1).to_i, 1 ].max
    buildings = Building.ordered
      .with_attached_cover_image
      .with_attached_gallery_images
      .offset((page - 1) * BUILDINGS_PER_PAGE)
      .limit(BUILDINGS_PER_PAGE + 1)
      .to_a

    @has_next_page = buildings.length > BUILDINGS_PER_PAGE
    @buildings = buildings.first(BUILDINGS_PER_PAGE)
    @next_page = page + 1 if @has_next_page
    @featured_building = @buildings.first
  end

  def show
    @contact_inquiry = ContactInquiry.new
    load_building_page(Building.where(slug: params[:slug]))
  end

  def autocomplete
    query = params[:q].to_s.strip
    return render json: [] if query.length < 2

    matches = Building
      .autocomplete_search(query)
      .ordered
      .limit(8)

    render json: matches.map { |building| autocomplete_result(building) }
  end

  private

  def autocomplete_result(building)
    {
      name: building.name,
      neighborhood: building.neighborhood,
      full_address: building.full_address,
      url: building_path(building)
    }
  end
end
