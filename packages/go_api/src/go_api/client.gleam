import gleam/bit_array
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/result
import gleam/string
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}
import gleam/uri
import palabres

import common/util
import go_api/departures
import go_api/destinations
import go_api/timetable

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

pub fn get_departures(
  client: Client,
  from: String,
) -> Result(departures.Departures, String) {
  let endpoint =
    "/external/go/departures/stops/" <> from <> "/status/departures"
  let query = [
    #("page", "1"),
    // Their API seems to ignore other types 
    #("transitTypeName", "All"),
    #("pageLimit", "20"),
  ]
  let assert Ok(response) = send_req(client, endpoint, query)
  case departures.parse(response.body) {
    Ok(departures) -> Ok(departures)
    Error(errors) -> Error(util.str_from_decode_errors(errors))
  }
}

pub fn get_destinations(
  client: Client,
  to: String,
  date: String,
) -> Result(destinations.Destinations, String) {
  let endpoint = "/external/go/schedules/stops/" <> to <> "/destinations"
  let query = [#("Date", date)]
  let assert Ok(response) = send_req(client, endpoint, query)
  case destinations.parse(response.body) {
    Ok(destinations) -> Ok(destinations)
    Error(errors) -> Error(util.str_from_decode_errors(errors))
  }
}

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

fn send_req(
  client: Client,
  endpoint: String,
  query: List(#(String, String)),
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

  log_request(req)
  let start = timestamp.system_time()

  let resp_with_err =
    result.try_recover(httpc.send_bits(req), normalize_httpc_error)
  use resp <- result.try(resp_with_err)

  let get_content_encoding = fn(r) {
    response.get_header(r, "content-encoding")
    |> result.replace_error("no content-encoding")
  }

  let content_encoding = get_content_encoding(resp)

  case content_encoding {
    Ok("gzip") -> handle_gzip(resp) |> log_response(start)
    Ok(_) -> handle_uncompressed(resp) |> log_response(start)
    Error(msg) -> Error(msg)
  }
}

fn normalize_httpc_error(e: httpc.HttpError) -> Result(a, String) {
  case e {
    httpc.InvalidUtf8Response -> Error("InvalidUtf8Response")
    httpc.FailedToConnect(_, _) -> Error("FailedToConnect")
    httpc.ResponseTimeout -> Error("ResponseTimeout")
  }
}

fn handle_gzip(res: Response(BitArray)) -> Result(Response(BitArray), String) {
  use decompressed <- result.try(gunzip(res.body))
  Ok(response.set_body(res, decompressed))
}

fn handle_uncompressed(
  res: response.Response(BitArray),
) -> Result(response.Response(BitArray), String) {
  Ok(res)
}

pub fn log_request(req: Request(BitArray)) {
  palabres.info("Request")
  |> palabres.string("path", req |> request.to_uri |> uri.to_string)
  |> palabres.log
}

pub fn log_response(
  res: Result(Response(BitArray), String),
  start: Timestamp,
) -> Result(Response(BitArray), String) {
  case res {
    Ok(resp) -> {
      let str_from_body = fn(body: BitArray) {
        case bit_array.to_string(body) {
          Ok(text) -> text
          Error(_) -> string.inspect(body)
        }
      }

      palabres.info("Response")
      |> palabres.int("status", resp.status)
      |> palabres.lazy(fn(log) {
        log
        |> palabres.int(
          "duration_ms",
          timestamp.difference(start, timestamp.system_time())
            |> duration.to_milliseconds,
        )
      })
      |> palabres.log

      palabres.debug("Response body")
      |> palabres.lazy(fn(log) {
        log
        |> palabres.string("body", str_from_body(resp.body))
      })
      |> palabres.log
    }
    Error(err) -> {
      palabres.error("Request failed")
      |> palabres.string("reason", err)
      |> palabres.log
    }
  }

  res
}

@external(erlang, "zlib_bridge", "gunzip")
fn gunzip(compressed: BitArray) -> Result(BitArray, String)
