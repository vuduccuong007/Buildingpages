class Building < ApplicationRecord
  AUTOCOMPLETE_SEARCH_PREDICATE =
    :name_or_neighborhood_or_street_address_or_city_i_cont

  has_one_attached :cover_image
  has_many_attached :gallery_images

  has_many :policies, -> { order(:position) }, dependent: :destroy
  has_many :apartment_listings, dependent: :destroy
  has_many :active_apartment_listings,
           -> { currently_available },
           class_name: "ApartmentListing",
           inverse_of: :building

  validates :name, :slug, :street_address, :city, presence: true
  validates :slug, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :ordered, -> { order(:position, :name) }

  def self.autocomplete_search(query)
    ransack(AUTOCOMPLETE_SEARCH_PREDICATE => query).result
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[city name neighborhood street_address]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def full_address
    [ street_address, city, state, postal_code ].compact_blank.join(", ")
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
