class ApartmentListing < ApplicationRecord
  belongs_to :building

  has_one_attached :photo
  has_many :contact_inquiries, dependent: :restrict_with_error

  enum :transaction_type, {
    rent: "rent",
    sale: "sale"
  }
  enum :status, {
    active: "active",
    inactive: "inactive"
  }

  validates :unit_number, :transaction_type, :status, presence: true
  validates :price_cents,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :bedrooms,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :bathrooms,
            presence: true,
            numericality: { greater_than: 0 }

  scope :currently_available, -> { active.order(:position, :unit_number) }
end
