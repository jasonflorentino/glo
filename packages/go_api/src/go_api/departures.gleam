import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}

import common/util.{decode_optional_null, nullable}

pub fn parse(data: BitArray) -> Result(Departures, List(decode.DecodeError)) {
  let assert Ok(raw_dynamic) =
    json.parse_bits(from: data, using: decode.dynamic)
  decode.run(raw_dynamic, departures_decoder_go())
}

pub type Departures {
  Departures(
    station_code: String,
    all_departures: Option(DeparturesPage),
    train_departures: Option(DeparturesPage),
    bus_departures: Option(DeparturesPage),
  )
}

pub fn departures_to_json(departures: Departures) -> json.Json {
  let Departures(
    station_code:,
    all_departures:,
    train_departures:,
    bus_departures:,
  ) = departures
  json.object([
    #("station_code", json.string(station_code)),
    #("all_departures", nullable(all_departures, departures_page_to_json)),
    #("train_departures", nullable(train_departures, departures_page_to_json)),
    #("bus_departures", nullable(bus_departures, departures_page_to_json)),
  ])
}

pub fn departures_decoder() -> decode.Decoder(Departures) {
  use station_code <- decode.field("station_code", decode.string)
  use all_departures <- decode_optional_null(
    "all_departures",
    departures_page_decoder(),
  )
  use train_departures <- decode_optional_null(
    "train_departures",
    departures_page_decoder(),
  )
  use bus_departures <- decode_optional_null(
    "bus_departures",
    departures_page_decoder(),
  )
  decode.success(Departures(
    station_code:,
    all_departures:,
    train_departures:,
    bus_departures:,
  ))
}

pub fn departures_decoder_go() -> decode.Decoder(Departures) {
  use station_code <- decode.field("stationCode", decode.string)
  use all_departures <- decode_optional_null(
    "allDepartures",
    departures_page_decoder_go(),
  )
  use train_departures <- decode_optional_null(
    "trainDepartures",
    departures_page_decoder_go(),
  )
  use bus_departures <- decode_optional_null(
    "busDepartures",
    departures_page_decoder_go(),
  )
  decode.success(Departures(
    station_code:,
    all_departures:,
    train_departures:,
    bus_departures:,
  ))
}

pub type DeparturesPage {
  DeparturesPage(
    items: List(Departure),
    page: Int,
    page_size: Int,
    total_item_count: Int,
  )
}

pub fn departures_page_to_json(departures_page: DeparturesPage) -> json.Json {
  let DeparturesPage(items:, page:, page_size:, total_item_count:) =
    departures_page
  json.object([
    #("items", json.array(items, departure_to_json)),
    #("page", json.int(page)),
    #("page_size", json.int(page_size)),
    #("total_item_count", json.int(total_item_count)),
  ])
}

pub fn departures_page_decoder() -> decode.Decoder(DeparturesPage) {
  use items <- decode.field("items", decode.list(departure_decoder()))
  use page <- decode.field("page", decode.int)
  use page_size <- decode.field("page_size", decode.int)
  use total_item_count <- decode.field("total_item_count", decode.int)
  decode.success(DeparturesPage(items:, page:, page_size:, total_item_count:))
}

pub fn departures_page_decoder_go() -> decode.Decoder(DeparturesPage) {
  use items <- decode.field("items", decode.list(departure_decoder_go()))
  use page <- decode.field("page", decode.int)
  use page_size <- decode.field("pageSize", decode.int)
  use total_item_count <- decode.field("totalItemCount", decode.int)
  decode.success(DeparturesPage(items:, page:, page_size:, total_item_count:))
}

pub type Departure {
  Departure(
    all_departure_stops: Option(AllDepartureStops),
    delayed_departure_time: Option(String),
    delay_message: Option(String),
    // May be negative
    delay_seconds: Option(Int),
    gate: Option(String),
    // "Proceed / Avncez"
    info: Option(String),
    line_code: String,
    // "#00853e"
    line_color: Option(String),
    line_message_en: Option(String),
    line_message_fr: Option(String),
    // "5 & 6"
    platform: String,
    // Wish tz offset! 2026-11-18T23:10:00-05:00
    scheduled_date_time: String,
    scheduled_platform: Option(String),
    // "18:48"
    scheduled_time: String,
    service: String,
    // "ontime"
    status: String,
    // "Bloor-Weston-Malton"
    stops_display: String,
    transit_type: Int,
    transit_type_name: String,
    trip_number: String,
    zone: Option(String),
  )
}

pub fn departure_to_json(departure: Departure) -> json.Json {
  let Departure(
    all_departure_stops:,
    delayed_departure_time:,
    delay_message:,
    delay_seconds:,
    gate:,
    info:,
    line_code:,
    line_color:,
    line_message_en:,
    line_message_fr:,
    platform:,
    scheduled_date_time:,
    scheduled_platform:,
    scheduled_time:,
    service:,
    status:,
    stops_display:,
    transit_type:,
    transit_type_name:,
    trip_number:,
    zone:,
  ) = departure

  json.object([
    #(
      "all_departure_stops",
      nullable(all_departure_stops, all_departure_stops_to_json),
    ),
    #("delayed_departure_time", nullable(delayed_departure_time, json.string)),
    #("delay_message", nullable(delay_message, json.string)),
    #("delay_seconds", nullable(delay_seconds, json.int)),
    #("gate", nullable(gate, json.string)),
    #("info", nullable(info, json.string)),
    #("line_code", json.string(line_code)),
    #("line_color", nullable(line_color, json.string)),
    #("line_message_en", nullable(line_message_en, json.string)),
    #("line_message_fr", nullable(line_message_fr, json.string)),
    #("platform", json.string(platform)),
    #("scheduled_date_time", json.string(scheduled_date_time)),
    #("scheduled_platform", nullable(scheduled_platform, json.string)),
    #("scheduled_time", json.string(scheduled_time)),
    #("service", json.string(service)),
    #("status", json.string(status)),
    #("stops_display", json.string(stops_display)),
    #("transit_type", json.int(transit_type)),
    #("transit_type_name", json.string(transit_type_name)),
    #("trip_number", json.string(trip_number)),
    #("zone", nullable(zone, json.string)),
  ])
}

pub fn departure_decoder() -> decode.Decoder(Departure) {
  use all_departure_stops <- decode.field(
    "all_departure_stops",
    decode.optional(all_departure_stops_decoder()),
  )
  use delayed_departure_time <- decode_optional_null(
    "delayed_departure_time",
    decode.string,
  )
  use delay_message <- decode_optional_null("delay_message", decode.string)
  use delay_seconds <- decode_optional_null("delay_seconds", decode.int)
  use gate <- decode_optional_null("gate", decode.string)
  use info <- decode_optional_null("info", decode.string)
  use line_code <- decode.field("line_code", decode.string)
  use line_color <- decode_optional_null("line_color", decode.string)
  use line_message_en <- decode_optional_null("line_message_en", decode.string)
  use line_message_fr <- decode_optional_null("line_message_fr", decode.string)
  use platform <- decode.field("platform", decode.string)
  use scheduled_date_time <- decode.field("scheduled_date_time", decode.string)
  use scheduled_platform <- decode_optional_null(
    "scheduled_platform",
    decode.string,
  )
  use scheduled_time <- decode.field("scheduled_time", decode.string)
  use service <- decode.field("service", decode.string)
  use status <- decode.field("status", decode.string)
  use stops_display <- decode.field("stops_display", decode.string)
  use transit_type <- decode.field("transit_type", decode.int)
  use transit_type_name <- decode.field("transit_type_name", decode.string)
  use trip_number <- decode.field("trip_number", decode.string)
  use zone <- decode_optional_null("zone", decode.string)
  decode.success(Departure(
    all_departure_stops:,
    delayed_departure_time:,
    delay_message:,
    delay_seconds:,
    gate:,
    info:,
    line_code:,
    line_color:,
    line_message_en:,
    line_message_fr:,
    platform:,
    scheduled_date_time:,
    scheduled_platform:,
    scheduled_time:,
    service:,
    status:,
    stops_display:,
    transit_type:,
    transit_type_name:,
    trip_number:,
    zone:,
  ))
}

pub fn departure_decoder_go() -> decode.Decoder(Departure) {
  use all_departure_stops <- decode.field(
    "allDepartureStops",
    decode.optional(all_departure_stops_decoder_go()),
  )
  use delayed_departure_time <- decode_optional_null(
    "delayedDepartureTime",
    decode.string,
  )
  use delay_message <- decode_optional_null("delayMessage", decode.string)
  use delay_seconds <- decode_optional_null("delaySeconds", decode.int)
  use gate <- decode_optional_null("gate", decode.string)
  use info <- decode_optional_null("info", decode.string)
  use line_code <- decode.field("lineCode", decode.string)
  use line_color <- decode_optional_null("lineColor", decode.string)
  use line_message_en <- decode_optional_null("lineMessageEn", decode.string)
  use line_message_fr <- decode_optional_null("lineMessageFr", decode.string)
  use platform <- decode.field("platform", decode.string)
  use scheduled_date_time <- decode.field("scheduledDateTime", decode.string)
  use scheduled_platform <- decode_optional_null(
    "scheduledPlatform",
    decode.string,
  )
  use scheduled_time <- decode.field("scheduledTime", decode.string)
  use service <- decode.field("service", decode.string)
  use status <- decode.field("status", decode.string)
  use stops_display <- decode.field("stopsDisplay", decode.string)
  use transit_type <- decode.field("transitType", decode.int)
  use transit_type_name <- decode.field("transitTypeName", decode.string)
  use trip_number <- decode.field("tripNumber", decode.string)
  use zone <- decode_optional_null("zone", decode.string)
  decode.success(Departure(
    all_departure_stops:,
    delayed_departure_time:,
    delay_message:,
    delay_seconds:,
    gate:,
    info:,
    line_code:,
    line_color:,
    line_message_en:,
    line_message_fr:,
    platform:,
    scheduled_date_time:,
    scheduled_platform:,
    scheduled_time:,
    service:,
    status:,
    stops_display:,
    transit_type:,
    transit_type_name:,
    trip_number:,
    zone:,
  ))
}

pub type AllDepartureStops {
  AllDepartureStops(
    // false
    stay_in_train: Bool,
    // ["1732"]
    trip_numbers: List(String),
    departure_details_list: List(DepartureDetail),
  )
}

pub fn all_departure_stops_to_json(
  all_departure_stops: AllDepartureStops,
) -> json.Json {
  let AllDepartureStops(stay_in_train:, trip_numbers:, departure_details_list:) =
    all_departure_stops
  json.object([
    #("stay_in_train", json.bool(stay_in_train)),
    #("trip_numbers", json.array(trip_numbers, json.string)),
    #(
      "departure_details_list",
      json.array(departure_details_list, departure_detail_to_json),
    ),
  ])
}

pub fn all_departure_stops_decoder() -> decode.Decoder(AllDepartureStops) {
  use stay_in_train <- decode.field("stay_in_train", decode.bool)
  use trip_numbers <- decode.field("trip_numbers", decode.list(decode.string))
  use departure_details_list <- decode.field(
    "departure_details_list",
    decode.list(departure_detail_decoder()),
  )
  decode.success(AllDepartureStops(
    stay_in_train:,
    trip_numbers:,
    departure_details_list:,
  ))
}

pub fn all_departure_stops_decoder_go() -> decode.Decoder(AllDepartureStops) {
  use stay_in_train <- decode.field("stayInTrain", decode.bool)
  use trip_numbers <- decode.field("tripNumbers", decode.list(decode.string))
  use departure_details_list <- decode.field(
    "departureDetailsList",
    decode.list(departure_detail_decoder_go()),
  )
  decode.success(AllDepartureStops(
    stay_in_train:,
    trip_numbers:,
    departure_details_list:,
  ))
}

pub type DepartureDetail {
  DepartureDetail(
    // "West Harbour GO"
    stop_name: String,
    // "19:24"
    departure_time: Option(String),
    // "WR"
    stop_code: String,
    // true
    is_major_stop: Bool,
  )
}

pub fn departure_detail_to_json(
  departure_detail: DepartureDetail,
) -> json.Json {
  let DepartureDetail(stop_name:, departure_time:, stop_code:, is_major_stop:) =
    departure_detail
  json.object([
    #("stop_name", json.string(stop_name)),
    #("depature_time", nullable(departure_time, json.string)),
    #("stop_code", json.string(stop_code)),
    #("is_major_stop", json.bool(is_major_stop)),
  ])
}

pub fn departure_detail_decoder() -> decode.Decoder(DepartureDetail) {
  use stop_name <- decode.field("stop_name", decode.string)
  use departure_time <- decode_optional_null("departure_time", decode.string)
  use stop_code <- decode.field("stop_code", decode.string)
  use is_major_stop <- decode.field("is_major_stop", decode.bool)
  decode.success(DepartureDetail(
    stop_name:,
    departure_time:,
    stop_code:,
    is_major_stop:,
  ))
}

pub fn departure_detail_decoder_go() -> decode.Decoder(DepartureDetail) {
  use stop_name <- decode.field("stopName", decode.string)
  use departure_time <- decode_optional_null("departureTime", decode.string)
  use stop_code <- decode.field("stopCode", decode.string)
  use is_major_stop <- decode.field("isMajorStop", decode.bool)
  decode.success(DepartureDetail(
    stop_name:,
    departure_time:,
    stop_code:,
    is_major_stop:,
  ))
}

/// Map of trip_number -> Departure
pub fn to_departure_map(departures: Departures) -> Dict(String, Departure) {
  case departures.all_departures {
    None -> dict.new()
    Some(departures_page) -> {
      list.map(departures_page.items, fn(d) { #(d.trip_number, d) })
      |> dict.from_list
    }
  }
}
