# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_26_133700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "apartment_listings", force: :cascade do |t|
    t.date "available_from"
    t.decimal "bathrooms", precision: 3, scale: 1, null: false
    t.decimal "bedrooms", precision: 3, scale: 1, default: "0.0", null: false
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "price_cents", null: false
    t.string "status", null: false
    t.string "transaction_type", null: false
    t.string "unit_number", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id", "status", "position", "unit_number"], name: "index_listings_on_building_status_and_order"
    t.index ["building_id", "status", "transaction_type"], name: "index_listings_on_building_status_and_transaction"
    t.index ["building_id"], name: "index_apartment_listings_on_building_id"
    t.check_constraint "bathrooms > 0::numeric", name: "apartment_listings_bathrooms_positive"
    t.check_constraint "bedrooms >= 0::numeric", name: "apartment_listings_bedrooms_non_negative"
    t.check_constraint "price_cents > 0", name: "apartment_listings_price_cents_positive"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "neighborhood"
    t.string "ownership_type"
    t.integer "position", default: 0, null: false
    t.string "postal_code"
    t.string "slug", null: false
    t.string "state"
    t.string "street_address", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_buildings_on_slug", unique: true
  end

  create_table "contact_inquiries", force: :cascade do |t|
    t.bigint "apartment_listing_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["apartment_listing_id"], name: "index_contact_inquiries_on_apartment_listing_id"
  end

  create_table "policies", force: :cascade do |t|
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.text "note"
    t.integer "position", default: 0, null: false
    t.string "section", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id", "section", "position"], name: "index_policies_on_building_section_and_position"
    t.index ["building_id"], name: "index_policies_on_building_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "apartment_listings", "buildings"
  add_foreign_key "contact_inquiries", "apartment_listings"
  add_foreign_key "policies", "buildings"
end
