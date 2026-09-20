import common/model.{Model, model_to_json}
import common/view
import gleam/erlang/process
import gleam/http.{Get}
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import go_api/timetable as go_timetable
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import services/go_trans
import wisp
import wisp/wisp_mist

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

pub fn handle_root(_req: wisp.Request) -> wisp.Response {
  let result = go_trans.fetch_timetable(option.None, option.None, option.None)
  let timetable = case result {
    Ok(timetable) ->
      timetable
      |> go_timetable.to_json
      |> json.to_string
    Error(_) -> "{}"
  }
  let error = case result {
    Ok(_) -> option.None
    Error(e) -> option.Some(e)
  }

  let initial_state = Model(count: 1, timetable:, error:)
  let html =
    html.html([], [
      html.head([], [
        html.title([], "App"),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href("/static/client.css"),
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
      html.body([], [
        html.div([attribute.id("app")], [view.view(initial_state)]),
      ]),
    ])

  html
  |> element.to_document_string
  |> wisp.html_response(200)
}

pub fn handle_ping(_req: wisp.Request) -> wisp.Response {
  wisp.ok()
  |> wisp.json_body("pong")
}

fn option_from_result(r: Result(a, _)) -> option.Option(a) {
  r
  |> result.map(option.Some)
  |> result.unwrap(or: option.None)
}

pub fn handle_timetable(req: wisp.Request) -> wisp.Response {
  let params = wisp.get_query(req)
  let from =
    params
    |> list.key_find("from")
    |> option_from_result
  let to = params |> list.key_find("to") |> option_from_result
  let date = params |> list.key_find("date") |> option_from_result
  let result = go_trans.fetch_timetable(from, to, date)

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
