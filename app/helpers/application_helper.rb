module ApplicationHelper
  MAP_LATITUDE_SPAN = 0.004
  MAP_LONGITUDE_SPAN = 0.006

  def building_map_embed_url(building)
    latitude = coordinate_value(building.latitude, -90..90)
    longitude = coordinate_value(building.longitude, -180..180)
    return if latitude.nil? || longitude.nil?

    bounds = [
      [ longitude - MAP_LONGITUDE_SPAN, -180 ].max,
      [ latitude - MAP_LATITUDE_SPAN, -90 ].max,
      [ longitude + MAP_LONGITUDE_SPAN, 180 ].min,
      [ latitude + MAP_LATITUDE_SPAN, 90 ].min
    ].map { |coordinate| coordinate.round(6) }.join(",")

    URI::HTTPS.build(
      host: "www.openstreetmap.org",
      path: "/export/embed.html",
      query: URI.encode_www_form(
        bbox: bounds,
        layer: "mapnik",
        marker: "#{latitude},#{longitude}"
      )
    ).to_s
  end

  def building_header_location(building)
    locality = [ building.city, building.state ].compact_blank.join(", ")
    [ locality, building.postal_code ].compact_blank.join(" ")
  end

  def formatted_room_count(value)
    number_with_precision(value, precision: 1, strip_insignificant_zeros: true)
  end

  private

  def coordinate_value(value, valid_range)
    coordinate = Float(value)
    coordinate if coordinate.finite? && valid_range.cover?(coordinate)
  rescue ArgumentError, TypeError
    nil
  end
end
