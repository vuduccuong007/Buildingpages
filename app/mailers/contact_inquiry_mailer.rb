class ContactInquiryMailer < ApplicationMailer
  def new_inquiry
    @inquiry = params[:inquiry]
    @listing = @inquiry.apartment_listing
    @building = @listing.building
    @formatted_price = ActionController::Base.helpers.number_to_currency(
      @listing.price_cents / 100.0,
      precision: @listing.price_cents.remainder(100).zero? ? 0 : 2
    )

    mail(
      to: ENV.fetch("CONTACT_RECIPIENT_EMAIL", "leasing@example.test"),
      subject: "Apartment inquiry: #{@building.name}, unit #{@listing.unit_number}"
    )
  end
end
