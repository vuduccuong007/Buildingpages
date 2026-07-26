class ContactInquiriesController < ApplicationController
  include BuildingPageLoadable

  def create
    listing = ApartmentListing.currently_available.find(params[:apartment_listing_id])
    @contact_inquiry = listing.contact_inquiries.build(contact_inquiry_params)

    if @contact_inquiry.save
      ContactInquiryMailer.with(inquiry: @contact_inquiry).new_inquiry.deliver_now

      redirect_to(
        building_path(listing.building, anchor: "apartment-listing-#{listing.id}"),
        notice: "Thanks! Your inquiry for unit #{listing.unit_number} has been received."
      )
    else
      @selected_listing = listing
      load_building_page(Building.where(id: listing.building_id))
      render "buildings/show", status: :unprocessable_content
    end
  end

  private

  def contact_inquiry_params
    params.expect(contact_inquiry: %i[name email phone message])
  end
end
