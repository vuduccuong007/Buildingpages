require "base64"
require "digest"

module DemoSeeds
  class MissingAssetError < StandardError; end

  ASSET_ROOT = Rails.root.join("db/seeds/assets")

  BUILDINGS = [
    {
      name: "One Sutton Place",
      slug: "one-sutton-place",
      street_address: "18 Sutton Place South",
      city: "New York",
      state: "NY",
      postal_code: "10022",
      neighborhood: "Sutton Place",
      ownership_type: "Condominium",
      description: "A refined East River residence with a limestone lobby, gracious layouts, and quiet landscaped outdoor space.",
      latitude: 40.756436,
      longitude: -73.961532,
      position: 1,
      cover: "buildings/buildings-01.jpeg",
      gallery: %w[
        galleries/galleries-01.jpg
        galleries/galleries-02.jpg
        galleries/galleries-03.jpg
        galleries/galleries-04.jpg
      ],
      year_built: 1928,
      residences: 46,
      amenities: "24-hour attended lobby, resident garden, bicycle storage, and package room.",
      transit: "Convenient to the E, M, 4, 5, 6, N, R, and W trains.",
      listings: [
        {
          unit_number: "14A", price_cents: 2_850_000_00, transaction_type: "sale",
          status: "active", bedrooms: 3, bathrooms: 2.5, available_from: Date.new(2026, 8, 1),
          position: 1, photo: "listings/listings-01.png"
        },
        {
          unit_number: "8C", price_cents: 9_500_00, transaction_type: "rent",
          status: "inactive", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 6, 15),
          position: 2, photo: "listings/listings-02.png"
        }
      ]
    },
    {
      name: "Dreamland Apartments",
      slug: "dreamland-apartments",
      street_address: "74-18 37th Avenue",
      city: "Jackson Heights",
      state: "NY",
      postal_code: "11372",
      neighborhood: "Jackson Heights",
      ownership_type: "Rental",
      description: "An art deco rental community centered on a planted courtyard, with bright homes and original prewar details.",
      latitude: 40.749828,
      longitude: -73.891672,
      position: 2,
      cover: "buildings/buildings-02.jpeg",
      gallery: %w[galleries/galleries-02.jpg],
      year_built: 1937,
      residences: 82,
      amenities: "Landscaped courtyard, laundry room, package lockers, and live-in superintendent.",
      transit: "Near the 74th Street-Broadway E, F, M, R, and 7 subway hub.",
      listings: [
        {
          unit_number: "5B", price_cents: 3_950_00, transaction_type: "rent",
          status: "active", bedrooms: 2, bathrooms: 1, available_from: Date.new(2026, 8, 15),
          position: 1, photo: "listings/listings-03.png"
        },
        {
          unit_number: "7D", price_cents: 995_000_00, transaction_type: "sale",
          status: "inactive", bedrooms: 2, bathrooms: 1.5, available_from: Date.new(2026, 5, 1),
          position: 2, photo: "listings/listings-04.png"
        }
      ]
    },
    {
      name: "Baumann Living",
      slug: "baumann-living",
      street_address: "241 Wythe Avenue",
      city: "Brooklyn",
      state: "NY",
      postal_code: "11249",
      neighborhood: "Williamsburg",
      ownership_type: "Condominium",
      description: "Contemporary Brooklyn homes pairing warm natural materials with oversized windows and a planted roof terrace.",
      latitude: 40.716215,
      longitude: -73.962418,
      position: 3,
      cover: "buildings/buildings-03.jpeg",
      gallery: %w[galleries/galleries-03.jpg],
      year_built: 2018,
      residences: 31,
      amenities: "Roof terrace, fitness studio, virtual doorman, cold storage, and private resident lounge.",
      transit: "A short walk to the Bedford Avenue L train and East River ferry.",
      listings: [
        {
          unit_number: "PH2", price_cents: 1_850_000_00, transaction_type: "sale",
          status: "active", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 9, 1),
          position: 1, photo: "listings/listings-05.png"
        },
        {
          unit_number: "3A", price_cents: 5_600_00, transaction_type: "rent",
          status: "inactive", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 4, 1),
          position: 2, photo: "listings/listings-01.png"
        }
      ]
    },
    {
      name: "South End Inc.",
      slug: "south-end-inc",
      street_address: "392 Lenox Avenue",
      city: "New York",
      state: "NY",
      postal_code: "10027",
      neighborhood: "Central Harlem",
      ownership_type: "Cooperative",
      description: "A resident-owned brownstone cooperative offering high ceilings, restored millwork, and a neighborly shared garden.",
      latitude: 40.811288,
      longitude: -73.944691,
      position: 4,
      cover: "buildings/buildings-04.jpeg",
      gallery: %w[galleries/galleries-04.jpg],
      year_built: 1906,
      residences: 18,
      amenities: "Shared garden, bicycle room, private storage cages, and video intercom.",
      transit: "Close to the 2 and 3 trains at 125th Street and several crosstown buses.",
      listings: [
        {
          unit_number: "2R", price_cents: 3_250_00, transaction_type: "rent",
          status: "active", bedrooms: 1, bathrooms: 1, available_from: Date.new(2026, 8, 1),
          position: 1, photo: "listings/listings-02.png"
        },
        {
          unit_number: "4F", price_cents: 785_000_00, transaction_type: "sale",
          status: "inactive", bedrooms: 2, bathrooms: 1, available_from: Date.new(2026, 3, 15),
          position: 2, photo: "listings/listings-03.png"
        }
      ]
    },
    {
      name: "Berry Lane Corporation",
      slug: "berry-lane-corporation",
      street_address: "166 Communipaw Avenue",
      city: "Jersey City",
      state: "NJ",
      postal_code: "07304",
      neighborhood: "Bergen-Lafayette",
      ownership_type: "Cooperative",
      description: "A brick cooperative near Berry Lane Park, known for spacious floor plans, leafy views, and easy light rail access.",
      latitude: 40.711938,
      longitude: -74.071214,
      position: 5,
      cover: "buildings/buildings-05.jpg",
      gallery: %w[galleries/galleries-05.jpg],
      year_built: 1964,
      residences: 64,
      amenities: "Resident parking, landscaped courtyard, laundry room, and secure package area.",
      transit: "Near the Garfield Avenue Hudson-Bergen Light Rail station.",
      listings: [
        {
          unit_number: "6A", price_cents: 625_000_00, transaction_type: "sale",
          status: "active", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 8, 20),
          position: 1, photo: "listings/listings-04.png"
        },
        {
          unit_number: "1C", price_cents: 2_900_00, transaction_type: "rent",
          status: "inactive", bedrooms: 1, bathrooms: 1, available_from: Date.new(2026, 2, 1),
          position: 2, photo: "listings/listings-05.png"
        }
      ]
    },
    {
      name: "York Place Apartments",
      slug: "york-place-apartments",
      street_address: "1683 York Avenue",
      city: "New York",
      state: "NY",
      postal_code: "10128",
      neighborhood: "Yorkville",
      ownership_type: "Rental",
      description: "A full-service Yorkville rental with practical layouts, river breezes, and welcoming shared spaces.",
      latitude: 40.777746,
      longitude: -73.945853,
      position: 6,
      cover: "buildings/buildings-06.jpg",
      gallery: %w[galleries/galleries-01.jpg],
      year_built: 1972,
      residences: 108,
      amenities: "24-hour doorman, fitness room, children's playroom, laundry, and roof deck.",
      transit: "Near the 86th Street Q train and M31 and M86 bus routes.",
      listings: [
        {
          unit_number: "9B", price_cents: 4_850_00, transaction_type: "rent",
          status: "active", bedrooms: 2, bathrooms: 1.5, available_from: Date.new(2026, 9, 1),
          position: 1, photo: "listings/listings-01.png"
        },
        {
          unit_number: "10A", price_cents: 1_195_000_00, transaction_type: "sale",
          status: "inactive", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 1, 15),
          position: 2, photo: "listings/listings-02.png"
        }
      ]
    },
    {
      name: "Sundarji Studios",
      slug: "sundarji-studios",
      street_address: "31-09 34th Street",
      city: "Astoria",
      state: "NY",
      postal_code: "11106",
      neighborhood: "Astoria",
      ownership_type: "Rental",
      description: "Compact, thoughtfully planned residences with abundant daylight and a creative, community-minded atmosphere.",
      latitude: 40.761829,
      longitude: -73.923447,
      position: 7,
      cover: "buildings/buildings-07.jpg",
      gallery: %w[galleries/galleries-02.jpg],
      year_built: 2020,
      residences: 27,
      amenities: "Co-working lounge, roof terrace, bicycle storage, and smart package room.",
      transit: "Close to the Broadway N and W station and the Q104 bus.",
      listings: [
        {
          unit_number: "3S", price_cents: 2_750_00, transaction_type: "rent",
          status: "active", bedrooms: 0, bathrooms: 1, available_from: Date.new(2026, 8, 10),
          position: 1, photo: "listings/listings-03.png"
        },
        {
          unit_number: "5N", price_cents: 690_000_00, transaction_type: "sale",
          status: "inactive", bedrooms: 1, bathrooms: 1, available_from: Date.new(2026, 5, 10),
          position: 2, photo: "listings/listings-04.png"
        }
      ]
    },
    {
      name: "Parsons Pads",
      slug: "parsons-pads",
      street_address: "88-12 Parsons Boulevard",
      city: "Jamaica",
      state: "NY",
      postal_code: "11432",
      neighborhood: "Jamaica",
      ownership_type: "Condominium",
      description: "Modern Queens residences with flexible interiors, generous terraces, and direct access to neighborhood conveniences.",
      latitude: 40.706378,
      longitude: -73.801834,
      position: 8,
      cover: "buildings/buildings-08.jpeg",
      gallery: %w[galleries/galleries-03.jpg],
      year_built: 2016,
      residences: 39,
      amenities: "Fitness center, resident terrace, attended lobby, and on-site parking.",
      transit: "Near the Parsons Boulevard F train and multiple Jamaica bus routes.",
      listings: [
        {
          unit_number: "2A", price_cents: 735_000_00, transaction_type: "sale",
          status: "active", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 8, 5),
          position: 1, photo: "listings/listings-05.png"
        },
        {
          unit_number: "4C", price_cents: 3_100_00, transaction_type: "rent",
          status: "inactive", bedrooms: 2, bathrooms: 1, available_from: Date.new(2026, 3, 1),
          position: 2, photo: "listings/listings-01.png"
        }
      ]
    },
    {
      name: "115 East 90th Street",
      slug: "115-east-90th-street",
      street_address: "115 East 90th Street",
      city: "New York",
      state: "NY",
      postal_code: "10128",
      neighborhood: "Carnegie Hill",
      ownership_type: "Rental",
      description: "A classic Carnegie Hill elevator building with well-proportioned apartments, attentive service, and Central Park nearby.",
      latitude: 40.782905,
      longitude: -73.953878,
      position: 9,
      cover: "buildings/buildings-09.jpeg",
      gallery: %w[galleries/galleries-04.jpg],
      year_built: 1925,
      residences: 58,
      amenities: "Elevator, laundry room, bicycle storage, live-in superintendent, and package room.",
      transit: "Near the 4, 5, and 6 trains at 86th Street and the M86 Select Bus.",
      listings: [
        {
          unit_number: "6F", price_cents: 1_800_00, transaction_type: "rent",
          status: "active", bedrooms: 1, bathrooms: 1, available_from: Date.new(2026, 8, 1),
          position: 1, photo: "listings/listings-01.png"
        },
        {
          unit_number: "1B", price_cents: 1_675_00, transaction_type: "rent",
          status: "active", bedrooms: 0, bathrooms: 1, available_from: Date.new(2026, 8, 1),
          position: 2, photo: "listings/listings-02.png"
        },
        {
          unit_number: "4A", price_cents: 2_200_00, transaction_type: "rent",
          status: "active", bedrooms: 2, bathrooms: 1, available_from: Date.new(2026, 8, 15),
          position: 3, photo: "listings/listings-03.png"
        },
        {
          unit_number: "3E", price_cents: 1_800_00, transaction_type: "rent",
          status: "active", bedrooms: 1, bathrooms: 1, available_from: Date.new(2026, 9, 1),
          position: 4, photo: "listings/listings-04.png"
        },
        {
          unit_number: "2C", price_cents: 2_125_00, transaction_type: "rent",
          status: "active", bedrooms: 1.5, bathrooms: 1, available_from: Date.new(2026, 9, 1),
          position: 5, photo: "listings/listings-05.png"
        },
        {
          unit_number: "5D", price_cents: 2_400_00, transaction_type: "rent",
          status: "active", bedrooms: 2, bathrooms: 1.5, available_from: Date.new(2026, 9, 15),
          position: 6, photo: "listings/listings-01.png"
        },
        {
          unit_number: "7A", price_cents: 2_350_00, transaction_type: "rent",
          status: "inactive", bedrooms: 1, bathrooms: 1, available_from: Date.new(2026, 4, 1),
          position: 7, photo: "listings/listings-02.png"
        }
      ]
    },
    {
      name: "Vinyl Villas",
      slug: "vinyl-villas",
      street_address: "960 Freeman Street",
      city: "Bronx",
      state: "NY",
      postal_code: "10459",
      neighborhood: "Longwood",
      ownership_type: "Condominium",
      description: "A music-inspired collection of airy homes built around a landscaped courtyard and flexible resident studio.",
      latitude: 40.825741,
      longitude: -73.892365,
      position: 10,
      cover: "buildings/buildings-10.jpg",
      gallery: %w[galleries/galleries-05.jpg],
      year_built: 2019,
      residences: 34,
      amenities: "Music practice room, landscaped courtyard, roof deck, and bicycle storage.",
      transit: "Near the Simpson Street 2 and 5 trains and the Bx5 bus.",
      listings: [
        {
          unit_number: "PH", price_cents: 925_000_00, transaction_type: "sale",
          status: "active", bedrooms: 3, bathrooms: 2, available_from: Date.new(2026, 10, 1),
          position: 1, photo: "listings/listings-03.png"
        },
        {
          unit_number: "4V", price_cents: 3_450_00, transaction_type: "rent",
          status: "inactive", bedrooms: 2, bathrooms: 2, available_from: Date.new(2026, 5, 15),
          position: 2, photo: "listings/listings-04.png"
        }
      ]
    }
  ].freeze

  module_function

  def asset_path(relative_path)
    path = ASSET_ROOT.join(relative_path)
    return path if path.file?

    raise MissingAssetError, "Required seed asset is missing: #{path}"
  end

  def validate_assets!
    BUILDINGS.flat_map do |building|
      [ building[:cover], *building[:gallery], *building[:listings].pluck(:photo) ]
    end.uniq.each { |relative_path| asset_path(relative_path) }
  end

  def blob_for(relative_path)
    path = asset_path(relative_path)
    checksum = Base64.strict_encode64(Digest::MD5.file(path).digest)
    attributes = {
      checksum: checksum,
      byte_size: path.size,
      filename: path.basename.to_s,
      service_name: ActiveStorage::Blob.service.name
    }

    blob = ActiveStorage::Blob.find_by(attributes)
    if blob
      unless blob.service.exist?(blob.key)
        path.open("rb") { |file| blob.service.upload(blob.key, file, checksum: checksum) }
      end
      return blob
    end

    path.open("rb") do |file|
      ActiveStorage::Blob.create_and_upload!(io: file, filename: path.basename.to_s)
    end
  end

  def attach_one(record, name, blob)
    attachment = record.public_send(name)
    return if attachment.attached? && attachment.blob_id == blob.id

    attachment.attach(blob)
  end

  def attach_many(record, name, blobs)
    association = record.public_send(name)
    wanted_ids = blobs.map(&:id)
    association.attachments.where.not(blob_id: wanted_ids).destroy_all
    attached_ids = association.attachments.reload.pluck(:blob_id)
    blobs.reject { |blob| attached_ids.include?(blob.id) }.each { |blob| association.attach(blob) }
  end

  def policy_attributes(building_data)
    [
      {
        section: "general", position: 1, title: "Pets",
        details: "Cats and dogs are welcome with prior written approval. A maximum of two pets is permitted per residence.",
        note: "Service and assistance animals are accommodated in accordance with applicable law."
      },
      {
        section: "general", position: 2, title: "Smoke-free building",
        details: "Smoking and vaping are not permitted inside residences, common areas, or within 25 feet of an entrance.",
        note: "This policy applies to residents, guests, contractors, and staff."
      },
      {
        section: "general", position: 3, title: "Move-ins and deliveries",
        details: "Move-ins, move-outs, and oversized deliveries must be reserved with management at least three business days in advance.",
        note: "Approved hours are Monday through Saturday, 9:00 a.m. to 5:00 p.m."
      },
      {
        section: "additional_information", position: 1, title: "Building profile",
        details: "Built in #{building_data[:year_built]} with #{building_data[:residences]} residences.",
        note: building_data[:ownership_type]
      },
      {
        section: "additional_information", position: 2, title: "Amenities",
        details: building_data[:amenities],
        note: "Availability and operating hours are subject to house rules."
      },
      {
        section: "additional_information", position: 3, title: "Transportation",
        details: building_data[:transit],
        note: "Travel times vary by service conditions."
      }
    ]
  end

  def seed!
    validate_assets!
    blobs = {}
    fetch_blob = ->(relative_path) { blobs[relative_path] ||= blob_for(relative_path) }

    BUILDINGS.each do |building_data|
      building = Building.find_or_initialize_by(slug: building_data[:slug])
      building.assign_attributes(building_data.slice(
        :name, :street_address, :city, :state, :postal_code, :neighborhood,
        :ownership_type, :description, :latitude, :longitude, :position
      ))
      building.save!

      attach_one(building, :cover_image, fetch_blob.call(building_data[:cover]))
      attach_many(building, :gallery_images, building_data[:gallery].map { |path| fetch_blob.call(path) })

      policy_attributes(building_data).each do |attributes|
        policy = building.policies.find_or_initialize_by(
          section: attributes[:section],
          position: attributes[:position]
        )
        policy.assign_attributes(attributes.slice(:title, :details, :note))
        policy.save!
      end

      building_data[:listings].each do |attributes|
        listing = building.apartment_listings.find_or_initialize_by(unit_number: attributes[:unit_number])
        listing.assign_attributes(attributes.except(:photo))
        listing.save!
        attach_one(listing, :photo, fetch_blob.call(attributes[:photo]))
      end
    end

    verify!
  end

  def verify!
    buildings = Building.where(slug: BUILDINGS.pluck(:slug)).includes(
      :policies,
      :cover_image_attachment,
      :gallery_images_attachments,
      apartment_listings: :photo_attachment
    )

    errors = []
    BUILDINGS.each do |building_data|
      building = buildings.find { |record| record.slug == building_data[:slug] }
      unless building
        errors << "building #{building_data[:slug]} was not seeded"
        next
      end

      errors << "#{building.slug} has no cover image" unless building.cover_image.attached?
      if building.gallery_images.attachments.size != building_data[:gallery].size
        errors << "#{building.slug} has #{building.gallery_images.attachments.size} gallery images; expected #{building_data[:gallery].size}"
      end

      building_data[:listings].each do |listing_data|
        listing = building.apartment_listings.find { |record| record.unit_number == listing_data[:unit_number] }
        errors << "#{building.slug} unit #{listing_data[:unit_number]} was not seeded" unless listing
        errors << "#{building.slug} unit #{listing_data[:unit_number]} has no photo" if listing && !listing.photo.attached?
      end
    end

    attachment_scope = ActiveStorage::Attachment.where(
      record_type: "Building",
      record_id: buildings.map(&:id)
    ).or(
      ActiveStorage::Attachment.where(
        record_type: "ApartmentListing",
        record_id: buildings.flat_map { |building| building.apartment_listings.map(&:id) }
      )
    ).includes(:blob)
    attachment_scope.each do |attachment|
      next if attachment.blob.service.exist?(attachment.blob.key)

      errors << "stored file is missing for #{attachment.record_type}##{attachment.record_id} #{attachment.name}: key #{attachment.blob.key}"
    end

    raise "Demo seed verification failed:\n- #{errors.join("\n- ")}" if errors.any?

    puts(
      "Seeded #{buildings.size} buildings, " \
      "#{buildings.sum { |building| building.policies.size }} policies, " \
      "#{buildings.sum { |building| building.apartment_listings.size }} listings, and " \
      "#{attachment_scope.size} attachments."
    )
  end
end

DemoSeeds.seed!
