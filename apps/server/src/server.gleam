import common/util
import gleam/erlang/process
import gleam/http.{Get}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import wisp
import wisp/wisp_mist

import client_sdk/model.{model_to_json}
import client_sdk/view
import go_api/departures as go_departures
import go_api/destinations as go_destinations
import go_api/stops.{type Stop}
import go_api/timetable as go_timetable
import services/go_trans

pub fn main() -> Nil {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(priv_directory) = wisp.priv_directory("server")
  let static_directory = priv_directory <> "/static"

  let assert Ok(_) =
    handle_request(static_directory, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start

  process.sleep_forever()
}

pub fn handle_request(
  static_directory: String,
  req: wisp.Request,
) -> wisp.Response {
  use req <- app_middleware(req, static_directory)

  case req.method, wisp.path_segments(req) {
    Get, [] -> handle_root(req)
    Get, ["ping"] -> handle_ping(req)

    Get, ["api", "destinations"] -> handle_destinations(req)
    Get, ["api", "timetable"] -> handle_timetable(req)

    _, _ -> wisp.not_found()
  }
}

pub fn app_middleware(
  req: wisp.Request,
  static_directory: String,
  next: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- wisp.csrf_known_header_protection(req)
  use <- wisp.serve_static(req, under: "/static", from: static_directory)

  next(req)
}

pub fn handle_root(req: wisp.Request) -> wisp.Response {
  // Handle explicit param input
  let params = wisp.get_query(req)
  let from =
    params
    |> list.key_find("from")
    |> option.from_result
  let to = params |> list.key_find("to") |> option.from_result
  let date = params |> list.key_find("date") |> option.from_result

  // Timetable
  // TODO: Consider whether we want to continue letting `fetch_timetable` allow Options or instead
  //       move the "default" stop logic up and out.
  let result = case from, to {
    None, None -> go_trans.fetch_timetable(from, to, date)
    Some(from), Some(to) -> {
      case from == to {
        True -> Error("Expected to and from to be different")
        False -> go_trans.fetch_timetable(Some(from), Some(to), date)
      }
    }
    _, _ -> Error("Only one stop")
  }
  let timetable = case result {
    Ok(timetable) -> Some(timetable)
    Error(_) -> None
  }
  let error = case result {
    Ok(_) -> None
    Error(e) -> Some(e)
  }

  // Pull fetched stops from the timetable
  let #(from_stop, to_stop) = case timetable {
    Some(timetable) -> {
      let from =
        stops.from_string(timetable.departure_stop_id)
        |> option.from_result
      let to =
        stops.from_string(timetable.arrival_stop_id) |> option.from_result
      #(from, to)
    }
    None -> #(None, None)
  }

  let to_stop_options = stops.get_stop_options(from_stop, to_stop)

  let timetable = case from_stop {
    Some(from) -> {
      use departures <- util.with_unwrap(
        go_trans.fetch_depatures(from),
        or: timetable,
      )
      let dep_map = go_departures.to_departure_map(departures)
      case timetable {
        Some(timetable) ->
          timetable |> go_timetable.enrich_with_departures(dep_map) |> Some
        None -> timetable
      }
    }
    None -> timetable
  }

  let initial_state =
    model.Model(
      ..model.empty_state(),
      timetable:,
      from_stop:,
      to_stop:,
      to_stop_options:,
      error:,
    )

  let html =
    html.html([attribute.lang("en")], [
      html.head([], [
        html.meta([attribute.charset("UTF-8")]),
        html.meta([
          attribute.name("viewport"),
          attribute.content("width=device-width, initial-scale=1"),
        ]),
        html.meta([
          attribute.name("description"),
          attribute.content("See GO Train schedules quickly and easily"),
        ]),
        html.title([], "GGTS"),
        html.link([
          attribute.rel("icon"),
          attribute.href(
            "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🚆</text></svg>",
          ),
        ]),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href("/static/client.css"),
        ]),
        html.link([
          attribute.rel("preconnect"),
          attribute.href("https://fonts.googleapis.com"),
        ]),
        html.link([
          attribute.rel("preconnect"),
          attribute.href("https://fonts.gstatic.com"),
        ]),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href(
            "https://fonts.googleapis.com/css2?family=Overpass:wght@100..900&display=swap",
          ),
        ]),
        html.script(
          [attribute.type_("module"), attribute.src("/static/client.js")],
          "",
        ),
        html.script(
          [attribute.type_("application/json"), attribute.id("model")],
          initial_state
            |> model_to_json
            |> json.to_string,
        ),
      ]),
      html.body(
        [
          attribute.class(
            "bg-stone-900 text-green-200 selection:bg-green-300 selection:text-green-900",
          ),
        ],
        [
          html.div([attribute.id("app")], [view.view(initial_state)]),
        ],
      ),
    ])

  html
  |> element.to_document_string
  |> wisp.html_response(200)
}

pub fn handle_ping(_req: wisp.Request) -> wisp.Response {
  wisp.ok()
  |> wisp.json_body("pong")
}

pub fn handle_destinations(req: wisp.Request) -> wisp.Response {
  let params = wisp.get_query(req)
  let to = params |> list.key_find("to") |> option.from_result
  let date = params |> list.key_find("date") |> option.from_result
  let result = go_trans.fetch_destinations(to, date)

  case result {
    Ok(api_res) -> {
      let json_res =
        api_res
        // Train trips only!
        |> go_destinations.train_only
        |> go_destinations.to_json
        |> json.to_string
      wisp.ok()
      |> wisp.json_body(json_res)
    }
    Error(msg) -> {
      wisp.internal_server_error()
      |> wisp.json_body(msg)
    }
  }
}

pub fn handle_timetable(req: wisp.Request) -> wisp.Response {
  let params = wisp.get_query(req)
  let from =
    params
    |> list.key_find("from")
    |> option.from_result
  let to = params |> list.key_find("to") |> option.from_result
  let date = params |> list.key_find("date") |> option.from_result

  use from <- required_param("from", from)
  use from_stop <- parsed_stop(from)

  let timetable = go_trans.fetch_timetable(Some(from), to, date)

  let timetable = {
    use departures <- util.with_unwrap(
      go_trans.fetch_depatures(from_stop),
      or: timetable,
    )
    let dep_map = go_departures.to_departure_map(departures)
    case timetable {
      Ok(timetable) ->
        timetable |> go_timetable.enrich_with_departures(dep_map) |> Ok
      Error(_) -> timetable
    }
  }

  case timetable {
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

fn required_param(
  name: String,
  val: Option(String),
  cb: fn(String) -> wisp.Response,
) {
  case val {
    None -> wisp.bad_request("Missing required param: " <> name)
    Some(val) -> cb(val)
  }
}

fn parsed_stop(maybe_stop: String, cb: fn(Stop) -> wisp.Response) {
  let stop = stops.from_string(maybe_stop)
  case stop {
    Error(_) -> wisp.bad_request("Expected stop, got: " <> maybe_stop)
    Ok(stop) -> cb(stop)
  }
}
