import gleam/erlang/process
import go_api/client as go_trans
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

pub fn handle_timetable(_req: wisp.Request) -> wisp.Response {
  let client = go_trans.new(go_trans.Config(go_trans.metrolinx_base, ""))
  let result = go_trans.get_timetable(client, "UN", "WR", "2026-09-10")

  case result {
    Ok(api_res) -> {
      wisp.ok()
      |> wisp.json_body(api_res.body)
    }
    Error(msg) -> {
      wisp.internal_server_error()
      |> wisp.json_body(msg)
    }
  }
}
