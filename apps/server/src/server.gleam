import common/util
import gleam/erlang/process
import gleam/json
import gleam/list
import gleam/result
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import go_api/client as go_client
import go_api/stops as go_stops
import go_api/timetable as go_timetable
import mist
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(handle_request, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- wisp.csrf_known_header_protection(req)

  handle_request(req)
}

pub fn handle_request(req: wisp.Request) -> wisp.Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    [] -> handle_root(req)
    ["ping"] -> handle_ping(req)
    ["timetable"] -> handle_timetable(req)

    _ -> wisp.not_found()
  }
}

pub fn handle_root(_req: wisp.Request) -> wisp.Response {
  let body = "<h1>Hello, World!</h1>"

  wisp.ok()
  |> wisp.html_body(body)
}

pub fn handle_ping(_req: wisp.Request) -> wisp.Response {
  wisp.ok()
  |> wisp.json_body("pong")
}

pub fn handle_timetable(req: wisp.Request) -> wisp.Response {
  let params = wisp.get_query(req)
  let now = timestamp.system_time()
  let from =
    params
    |> list.key_find("from")
    |> result.unwrap(or: get_default_from(now))
  echo "from" <> from
  let to =
    params |> list.key_find("to") |> result.unwrap(or: get_default_to(now))
  echo "to" <> to
  let date =
    params |> list.key_find("date") |> result.unwrap(or: get_default_date(now))
  echo "date" <> date
  let client = go_client.new(go_client.Config(go_client.metrolinx_base, ""))
  let result = go_client.get_timetable(client, from, to, date)

  case result {
    Ok(api_res) -> {
      wisp.ok()
      |> wisp.json_body(json.to_string(go_timetable.to_json(api_res)))
    }
    Error(msg) -> {
      wisp.internal_server_error()
      |> wisp.json_body(msg)
    }
  }
}

fn get_default_date(now: timestamp.Timestamp) -> String {
  let d = case util.is_yesterday(now) {
    True -> timestamp.subtract(now, duration.hours(24))
    False -> now
  }
  let #(d, _) = timestamp.to_calendar(d, calendar.utc_offset)
  util.to_date_str(d)
}

fn get_default_from(now: timestamp.Timestamp) -> String {
  case util.is_morning(now) {
    True -> go_stops.to_code(go_stops.WestHarbour)
    False -> go_stops.to_code(go_stops.UnionStation)
  }
}

fn get_default_to(now: timestamp.Timestamp) -> String {
  case util.is_morning(now) {
    True -> go_stops.to_code(go_stops.UnionStation)
    False -> go_stops.to_code(go_stops.WestHarbour)
  }
}
