class Policy < ApplicationRecord
  belongs_to :building

  enum :section, {
    general: "general",
    additional_information: "additional_information"
  }

  validates :section, :title, presence: true

  scope :ordered, -> { order(:position) }
end
