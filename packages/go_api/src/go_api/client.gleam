import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/result
import go_api/timetable
import go_api/util

pub const metrolinx_base = "https://api.metrolinx.com"

pub type Config {
  Config(base: String, api_key: String)
}

pub type Client {
  Client(config: Config)
}

pub fn new(config: Config) -> Client {
  Client(config)
}

pub type ApiError {
  ApiError(message: String)
}

type Query =
  List(#(String, String))

@external(erlang, "zlib_bridge", "gunzip")
fn gunzip(compressed: BitArray) -> Result(BitArray, String)

pub fn get_timetable(
  client: Client,
  from: String,
  to: String,
  date: String,
) -> Result(timetable.Timetable, String) {
  let endpoint = "/external/go/schedules/en/timetable/all"
  let query = [#("fromStop", from), #("toStop", to), #("date", date)]
  let assert Ok(response) = send_req(client, endpoint, query)
  case timetable.parse(response.body) {
    Ok(timetable) -> Ok(timetable)
    Error(errors) -> Error(util.str_from_decode_errors(errors))
  }
}

fn normalize_httpc_error(e: httpc.HttpError) -> Result(a, String) {
  case e {
    httpc.InvalidUtf8Response -> Error("InvalidUtf8Response")
    httpc.FailedToConnect(_, _) -> Error("FailedToConnect")
    httpc.ResponseTimeout -> Error("ResponseTimeout")
  }
}

fn send_req(
  client: Client,
  endpoint: String,
  query: Query,
) -> Result(response.Response(BitArray), String) {
  let assert Ok(base_req) = request.to(client.config.base <> endpoint)

  let req =
    base_req
    |> request.set_header("accept", "*/*")
    |> request.set_header("accept-encoding", "gzip")
    |> request.set_header("accept-language", "en-US,en;q=0.5")
    |> request.set_header("cache-control", "no-cache")
    |> request.set_header("connection", "keep-alive")
    |> request.set_header("host", "api.metrolinx.com")
    |> request.set_header("origin", "https://www.gotransit.com")
    |> request.set_header("pragma", "no-cache")
    |> request.set_header("priority", "u=0")
    |> request.set_header("referer", "https://www.gotransit.com/")
    |> request.set_header("sec-fetch-dest", "empty")
    |> request.set_header("sec-fetch-mode", "cors")
    |> request.set_header("sec-fetch-site", "same-site")
    |> request.set_query(query)
    |> request.set_method(http.Get)
    |> request.set_body(<<>>)

  let resp_with_err =
    result.try_recover(httpc.send_bits(req), normalize_httpc_error)
  use resp <- result.try(resp_with_err)

  let get_content_encoding = fn(r) {
    response.get_header(r, "content-encoding")
    |> result.replace_error("no content-encoding")
  }

  let content_encoding = get_content_encoding(resp)

  case content_encoding {
    Ok("gzip") -> handle_gzip(resp)
    Ok(_) -> handle_uncompressed(resp)
    Error(msg) -> Error(msg)
  }
}

fn handle_gzip(
  res: response.Response(BitArray),
) -> Result(response.Response(BitArray), String) {
  use decompressed <- result.try(gunzip(res.body))
  Ok(response.set_body(res, decompressed))
}

fn handle_uncompressed(
  res: response.Response(BitArray),
) -> Result(response.Response(BitArray), String) {
  Ok(res)
}
