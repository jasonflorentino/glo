import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import go_api/stops.{UnionStation, WestHarbour}
import go_api/timetable

pub type Model {
  Model(
    timetable: Option(timetable.Timetable),
    from_stop: stops.Stop,
    to_stop: stops.Stop,
    to_stop_options: Option(List(stops.Stop)),
    error: Option(String),
  )
}

pub fn empty_state() {
  Model(
    timetable: option.None,
    from_stop: WestHarbour,
    to_stop: UnionStation,
    to_stop_options: stops.get_sister_stops(WestHarbour),
    error: option.Some("empty"),
  )
}

pub fn model_to_json(model: Model) -> json.Json {
  let Model(timetable:, from_stop:, to_stop:, to_stop_options:, error:) = model
  json.object([
    #("timetable", case timetable {
      option.None -> json.null()
      option.Some(value) -> timetable.to_json(value)
    }),
    #("from_stop", stops.to_json(from_stop)),
    #("to_stop", stops.to_json(to_stop)),
    #(
      "to_stop_options",
      json.nullable(to_stop_options, of: json.array(_, of: stops.to_json)),
    ),
    #("error", case error {
      option.None -> json.null()
      option.Some(value) -> json.string(value)
    }),
  ])
}

pub fn model_decoder() -> decode.Decoder(Model) {
  use timetable <- decode.field(
    "timetable",
    decode.optional(timetable.decoder_json()),
  )
  use from_stop <- decode.field("from_stop", stops.decoder())
  use to_stop <- decode.field("from_stop", stops.decoder())
  use to_stop_options <- decode.field(
    "to_stop_options",
    decode.optional(decode.list(stops.decoder())),
  )
  use error <- decode.field("error", decode.optional(decode.string))
  decode.success(Model(
    timetable:,
    from_stop:,
    to_stop:,
    to_stop_options:,
    error:,
  ))
}
