import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import go_api/timetable

pub type Model {
  Model(
    count: Int,
    timetable: Option(timetable.Timetable),
    error: Option(String),
  )
}

pub const empty_state = Model(
  count: 0,
  timetable: option.None,
  error: option.Some("empty"),
)

pub fn model_to_json(model: Model) -> json.Json {
  let Model(count:, timetable:, error:) = model
  json.object([
    #("count", json.int(count)),
    #("timetable", case timetable {
      option.None -> json.null()
      option.Some(value) -> timetable.to_json(value)
    }),
    #("error", case error {
      option.None -> json.null()
      option.Some(value) -> json.string(value)
    }),
  ])
}

pub fn model_decoder() -> decode.Decoder(Model) {
  use count <- decode.field("count", decode.int)
  use timetable <- decode.field(
    "timetable",
    decode.optional(timetable.decoder_json()),
  )
  use error <- decode.field("error", decode.optional(decode.string))
  decode.success(Model(count:, timetable:, error:))
}
