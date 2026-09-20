import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

pub type Model {
  Model(count: Int, error: Option(String))
}

pub fn model_to_json(model: Model) -> json.Json {
  let Model(count:, error:) = model
  json.object([
    #("count", json.int(count)),
    #("error", case error {
      option.None -> json.null()
      option.Some(value) -> json.string(value)
    }),
  ])
}

pub fn model_decoder() -> decode.Decoder(Model) {
  use count <- decode.field("count", decode.int)
  use error <- decode.field("error", decode.optional(decode.string))
  decode.success(Model(count:, error:))
}
