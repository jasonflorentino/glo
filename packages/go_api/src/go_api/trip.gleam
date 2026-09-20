import gleam/dynamic/decode
import gleam/json

pub type Trip {
  Trip(
    arrival_time_display: String,
    departure_time_display: String,
    duration_minutes: Int,
    // A list of actual legs of the journey but since we're only interested in
    // direct train trips this list always contains the one rail leg that matches
    // the requested departure and destination:
    // lines: List(Line),

    // 8601 utc datetime
    order_time: String,
    service_code: String,
    service_name: String,
    transfers: Int,
    // 0 BUS
    // 1 RAIL
    // 2 ALL 
    transit_type: Int,
  )
}

pub fn decoder() -> decode.Decoder(Trip) {
  use arrival_time_display <- decode.field("arrivalTimeDisplay", decode.string)
  use departure_time_display <- decode.field(
    "departureTimeDisplay",
    decode.string,
  )
  use duration_minutes <- decode.field("durationMinutes", decode.int)
  use order_time <- decode.field("orderTime", decode.string)
  use service_code <- decode.field("serviceCode", decode.string)
  use service_name <- decode.field("serviceName", decode.string)
  use transfers <- decode.field("transfers", decode.int)
  use transit_type <- decode.field("transitType", decode.int)
  decode.success(Trip(
    arrival_time_display:,
    departure_time_display:,
    duration_minutes:,
    order_time:,
    service_code:,
    service_name:,
    transfers:,
    transit_type:,
  ))
}

pub fn to_json(trip: Trip) -> json.Json {
  let Trip(
    arrival_time_display:,
    departure_time_display:,
    duration_minutes:,
    order_time:,
    service_code:,
    service_name:,
    transfers:,
    transit_type:,
  ) = trip
  json.object([
    #("arrival_time_display", json.string(arrival_time_display)),
    #("departure_time_display", json.string(departure_time_display)),
    #("duration_minutes", json.int(duration_minutes)),
    #("order_time", json.string(order_time)),
    #("service_code", json.string(service_code)),
    #("service_name", json.string(service_name)),
    #("transfers", json.int(transfers)),
    #("transit_type", json.int(transit_type)),
  ])
}

const rail = 1

pub fn is_rail(t: Trip) -> Bool {
  t.transit_type == rail
}
