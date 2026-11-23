import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{Some}
import gleam/time/timestamp

import common/util
import go_api/departures.{type Departure}
import go_api/trip.{Trip}

pub type Timetable {
  Timetable(
    arrival_display: String,
    arrival_stop_id: String,
    // 2026-11-22T00:00:00-05:00
    date: String,
    departure_display: String,
    departure_stop_id: String,
    // service_code: String,
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

pub fn only_direct_train_trips(timetable: Timetable) -> Timetable {
  Timetable(
    ..timetable,
    trips: timetable.trips
      |> list.filter(fn(t) { trip.is_direct(t) && trip.is_rail(t) }),
  )
}

/// Assumes the timetable's trips are already ordered
pub fn only_recent_trios(
  timetable: Timetable,
  now: timestamp.Timestamp,
) -> Timetable {
  let #(departed, upcoming) =
    timetable.trips
    |> list.partition(with: fn(t) { util.is_before(t.order_time, now) })
  let most_recently_past = case departed |> list.reverse |> list.first {
    Ok(trip) -> [trip]
    Error(_) -> []
  }

  Timetable(..timetable, trips: list.append(most_recently_past, upcoming))
}

pub fn enrich_with_departures(
  timetable: Timetable,
  departures_map: Dict(String, Departure),
) -> Timetable {
  Timetable(
    ..timetable,
    trips: list.map(timetable.trips, fn(trip) {
      use line <- util.with_unwrap(list.first(trip.lines), or: trip)
      use dep <- util.with_unwrap(
        dict.get(departures_map, line.trip_number),
        or: trip,
      )
      Trip(
        ..trip,
        x_is_express: Some(line.is_express),
        x_platform: Some(dep.platform),
      )
    }),
  )
}
