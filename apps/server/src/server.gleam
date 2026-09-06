import gleam/erlang/process
import gleam/io
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

  io.println("Hello from server!")

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
  use _req <- middleware(req)

  let body = "<h1>Hello, World!</h1>"

  wisp.html_response(body, 200)
}
