import gleam/dynamic/decode
import gleam/json

pub type Destinations =
  List(Destination)

pub type Destination {
  Destination(code: String, name: String, transit_type: String)
}

pub fn destination_to_json(destination: Destination) -> json.Json {
  let Destination(code:, name:, transit_type:) = destination
  json.object([
    #("code", json.string(code)),
    #("name", json.string(name)),
    #("transit_type", json.string(transit_type)),
  ])
}

pub fn destination_decoder_json() -> decode.Decoder(Destination) {
  use code <- decode.field("code", decode.string)
  use name <- decode.field("name", decode.string)
  use transit_type <- decode.field("transit_type", decode.string)
  decode.success(Destination(code:, name:, transit_type:))
}

pub fn destination_decoder_go() -> decode.Decoder(Destination) {
  use code <- decode.field("code", decode.string)
  use name <- decode.field("name", decode.string)
  use transit_type <- decode.field("transitType", decode.string)
  decode.success(Destination(code:, name:, transit_type:))
}

pub fn parse(data: BitArray) -> Result(Destinations, List(decode.DecodeError)) {
  let assert Ok(raw_dynamic) =
    json.parse_bits(from: data, using: decode.dynamic)
  decode.run(raw_dynamic, decode.list(destination_decoder_go()))
}
