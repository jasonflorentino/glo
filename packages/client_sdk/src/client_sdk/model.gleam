import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

pub type Model {
  Model(count: Int, timetable: String, error: Option(String))
}

pub const empty_state = Model(
  count: 0,
  timetable: "{}",
  error: option.Some("empty"),
)

pub fn model_to_json(model: Model) -> json.Json {
  let Model(count:, timetable:, error:) = model
  json.object([
    #("count", json.int(count)),
    #("timetable", json.string(timetable)),
    #("error", case error {
      option.None -> json.null()
      option.Some(value) -> json.string(value)
    }),
  ])
}

pub fn model_decoder() -> decode.Decoder(Model) {
  use count <- decode.field("count", decode.int)
  use timetable <- decode.field("timetable", decode.string)
  use error <- decode.field("error", decode.optional(decode.string))
  decode.success(Model(count:, timetable:, error:))
}
