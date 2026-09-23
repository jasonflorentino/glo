import gleam/dynamic/decode
import gleam/json
import go_api/trip

pub type Timetable {
  Timetable(
    arrival_display: String,
    arrival_stop_id: String,
    date: String,
    departure_display: String,
    departure_stop_id: String,
    service_name: String,
    trips: List(trip.Trip),
  )
}

/// For decoding Go Transit's response bytes 
pub fn decoder_go() -> decode.Decoder(Timetable) {
  use arrival_display <- decode.field("arrivalDisplay", decode.string)
  use arrival_stop_id <- decode.field("arrivalStopId", decode.string)
  use date <- decode.field("date", decode.string)
  use departure_display <- decode.field("departureDisplay", decode.string)
  use departure_stop_id <- decode.field("departureStopId", decode.string)
  use service_name <- decode.field("serviceName", decode.string)
  use trips <- decode.field("trips", decode.list(trip.decoder_go()))
  decode.success(Timetable(
    arrival_display:,
    arrival_stop_id:,
    date:,
    departure_display:,
    departure_stop_id:,
    service_name:,
    trips:,
  ))
}

/// For decoding our own JSON
pub fn decoder_json() -> decode.Decoder(Timetable) {
  use arrival_display <- decode.field("arrival_display", decode.string)
  use arrival_stop_id <- decode.field("arrival_stop_id", decode.string)
  use date <- decode.field("date", decode.string)
  use departure_display <- decode.field("departure_display", decode.string)
  use departure_stop_id <- decode.field("departure_stop_id", decode.string)
  use service_name <- decode.field("service_name", decode.string)
  use trips <- decode.field("trips", decode.list(trip.decoder_json()))
  decode.success(Timetable(
    arrival_display:,
    arrival_stop_id:,
    date:,
    departure_display:,
    departure_stop_id:,
    service_name:,
    trips:,
  ))
}

pub fn parse(data: BitArray) -> Result(Timetable, List(decode.DecodeError)) {
  let assert Ok(raw_dynamic) =
    json.parse_bits(from: data, using: decode.dynamic)
  decode.run(raw_dynamic, decoder_go())
}

pub fn to_json(timetable: Timetable) -> json.Json {
  let Timetable(
    arrival_display:,
    arrival_stop_id:,
    date:,
    departure_display:,
    departure_stop_id:,
    service_name:,
    trips:,
  ) = timetable
  json.object([
    #("arrival_display", json.string(arrival_display)),
    #("arrival_stop_id", json.string(arrival_stop_id)),
    #("date", json.string(date)),
    #("departure_display", json.string(departure_display)),
    #("departure_stop_id", json.string(departure_stop_id)),
    #("service_name", json.string(service_name)),
    #("trips", json.array(trips, trip.to_json)),
  ])
}
