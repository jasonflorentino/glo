import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None}
import gleam/time/timestamp.{type Timestamp}

import common/util

pub type Trip {
  Trip(
    arrival_time_display: String,
    departure_time_display: String,
    // "02:05:00"
    // duration: String,
    duration_minutes: Int,
    // A list of actual legs of the journey but since we're only interested in
    // direct train trips this list always contains the one rail leg that matches
    // the requested departure and destination:
    lines: List(Line),
    // 2026-11-22T06:40:00 (Note no tz offset)
    order_time: Timestamp,
    // "01"
    service_code: String,
    service_name: String,
    transfers: Int,
    // 0 BUS
    // 1 RAIL
    // 2 BOTH 
    transit_type: Int,
    // glo only
    x_is_express: Option(Bool),
    x_platform: Option(String),
  )
}

/// For decoding Go api response bytes
pub fn decoder_go() -> decode.Decoder(Trip) {
  use arrival_time_display <- decode.field("arrivalTimeDisplay", decode.string)
  use departure_time_display <- decode.field(
    "departureTimeDisplay",
    decode.string,
  )
  use duration_minutes <- decode.field("durationMinutes", decode.int)
  use lines <- decode.field("lines", decode.list(line_decoder_go()))
  use order_time <- decode.field("orderTime", util.timestamp_decoder())
  use service_code <- decode.field("serviceCode", decode.string)
  use service_name <- decode.field("serviceName", decode.string)
  use transfers <- decode.field("transfers", decode.int)
  use transit_type <- decode.field("transitType", decode.int)
  decode.success(Trip(
    arrival_time_display:,
    departure_time_display:,
    duration_minutes:,
    lines:,
    order_time:,
    service_code:,
    service_name:,
    transfers:,
    transit_type:,
    // glo only
    x_is_express: None,
    x_platform: None,
  ))
}

/// For decoding our own JSON
pub fn decoder_json() -> decode.Decoder(Trip) {
  use arrival_time_display <- decode.field(
    "arrival_time_display",
    decode.string,
  )
  use departure_time_display <- decode.field(
    "departure_time_display",
    decode.string,
  )
  use duration_minutes <- decode.field("duration_minutes", decode.int)
  use lines <- decode.field("lines", decode.list(line_decoder()))
  use order_time <- decode.field("order_time", util.timestamp_decoder())
  use service_code <- decode.field("service_code", decode.string)
  use service_name <- decode.field("service_name", decode.string)
  use transfers <- decode.field("transfers", decode.int)
  use transit_type <- decode.field("transit_type", decode.int)
  use x_is_express <- decode.field("x_is_express", decode.optional(decode.bool))
  use x_platform <- decode.field("x_platform", decode.optional(decode.string))
  decode.success(Trip(
    arrival_time_display:,
    departure_time_display:,
    duration_minutes:,
    lines:,
    order_time:,
    service_code:,
    service_name:,
    transfers:,
    transit_type:,
    x_is_express:,
    x_platform:,
  ))
}

pub fn to_json(trip: Trip) -> json.Json {
  let Trip(
    arrival_time_display:,
    departure_time_display:,
    duration_minutes:,
    lines:,
    order_time:,
    service_code:,
    service_name:,
    transfers:,
    transit_type:,
    x_is_express:,
    x_platform:,
  ) = trip
  json.object([
    #("arrival_time_display", json.string(arrival_time_display)),
    #("departure_time_display", json.string(departure_time_display)),
    #("duration_minutes", json.int(duration_minutes)),
    #("lines", json.array(lines, line_to_json)),
    #("order_time", util.timestamp_to_json(order_time)),
    #("service_code", json.string(service_code)),
    #("service_name", json.string(service_name)),
    #("transfers", json.int(transfers)),
    #("transit_type", json.int(transit_type)),
    #("x_is_express", json.nullable(x_is_express, json.bool)),
    #("x_platform", json.nullable(x_platform, json.string)),
  ])
}

const rail = 1

pub fn is_rail(t: Trip) -> Bool {
  t.transit_type == rail
}

pub fn is_direct(t: Trip) -> Bool {
  t.transfers == 0
}

pub type Line {
  Line(is_express: Bool, trip_number: String)
}

fn line_to_json(line: Line) -> json.Json {
  let Line(is_express:, trip_number:) = line
  json.object([
    #("is_express", json.bool(is_express)),
    #("trip_number", json.string(trip_number)),
  ])
}

fn line_decoder() -> decode.Decoder(Line) {
  use is_express <- decode.field("is_express", decode.bool)
  use trip_number <- decode.field("trip_number", decode.string)
  decode.success(Line(is_express:, trip_number:))
}

fn line_decoder_go() -> decode.Decoder(Line) {
  use is_express <- decode.field("isExpress", decode.bool)
  use trip_number <- decode.field("tripNumber", decode.string)
  decode.success(Line(is_express:, trip_number:))
}
