class CreateBuildingPagesDomain < ActiveRecord::Migration[8.1]
  def change
    create_table :buildings do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :street_address, null: false
      t.string :city, null: false
      t.string :state
      t.string :postal_code
      t.string :neighborhood
      t.string :ownership_type
      t.text :description
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :buildings, :slug, unique: true

    create_table :policies do |t|
      t.references :building, null: false, foreign_key: true
      t.string :section, null: false
      t.string :title, null: false
      t.text :details
      t.text :note
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :policies,
              %i[building_id section position],
              name: "index_policies_on_building_section_and_position"

    create_table :apartment_listings do |t|
      t.references :building, null: false, foreign_key: true
      t.string :unit_number, null: false
      t.bigint :price_cents, null: false
      t.string :transaction_type, null: false
      t.string :status, null: false
      t.decimal :bedrooms, precision: 3, scale: 1, null: false, default: 0
      t.decimal :bathrooms, precision: 3, scale: 1, null: false
      t.date :available_from
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :apartment_listings,
                         "price_cents > 0",
                         name: "apartment_listings_price_cents_positive"
    add_check_constraint :apartment_listings,
                         "bedrooms >= 0",
                         name: "apartment_listings_bedrooms_non_negative"
    add_check_constraint :apartment_listings,
                         "bathrooms > 0",
                         name: "apartment_listings_bathrooms_positive"
    add_index :apartment_listings,
              %i[building_id status transaction_type],
              name: "index_listings_on_building_status_and_transaction"
    add_index :apartment_listings,
              %i[building_id status position unit_number],
              name: "index_listings_on_building_status_and_order"

    create_table :contact_inquiries do |t|
      t.references :apartment_listing, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :message, null: false

      t.timestamps
    end
  end
end
