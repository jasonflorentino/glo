import gleam/dynamic/decode
import gleam/list
import gleam/string

pub fn str_from_decode_errors(errors: List(decode.DecodeError)) -> String {
  errors
  |> list.map(fn(err) {
    let path = string.join(err.path, with: ".")
    string.join(
      [path, ": ", "Expected ", err.expected, ", found ", err.found],
      "",
    )
  })
  |> string.join(", ")
}
