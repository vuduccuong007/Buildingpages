require "uri"

class ContactInquiry < ApplicationRecord
  belongs_to :apartment_listing

  validates :name, :email, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
