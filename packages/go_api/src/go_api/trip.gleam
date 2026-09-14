import gleam/dynamic/decode
import gleam/json

pub type Trip {
  Trip(
    arrival_time_display: String,
    departure_time_display: String,
    duration_minutes: Int,
    order_time: String,
    transfers: Int,
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
  use transfers <- decode.field("transfers", decode.int)
  use transit_type <- decode.field("transitType", decode.int)
  decode.success(Trip(
    arrival_time_display:,
    departure_time_display:,
    duration_minutes:,
    order_time:,
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
    transfers:,
    transit_type:,
  ) = trip
  json.object([
    #("arrival_time_display", json.string(arrival_time_display)),
    #("departure_time_display", json.string(departure_time_display)),
    #("duration_minutes", json.int(duration_minutes)),
    #("order_time", json.string(order_time)),
    #("transfers", json.int(transfers)),
    #("transit_type", json.int(transit_type)),
  ])
}
