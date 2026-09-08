import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/result

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

type GetScheduleResponse =
  response.Response(String)

type Stop =
  String

type Query =
  List(#(String, String))

pub fn get_timetable(
  client: Client,
  from: Stop,
  to: String,
  date: String,
) -> Result(GetScheduleResponse, String) {
  let endpoint = "/external/go/schedules/en/timetable/all"
  let query = [#("fromStop", from), #("toStop", to), #("date", date)]
  send_req(client, endpoint, query)
}

fn normalize_http_error(e: httpc.HttpError) -> Result(_, String) {
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
) -> Result(response.Response(String), String) {
  let assert Ok(base_req) = request.to(client.config.base <> endpoint)

  let req =
    base_req
    |> request.set_header("accept", "*/*")
    |> request.set_header("accept-encoding", "identity")
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

  // TODO: Seeing InvaidUtf8Response. Update to use `send_bits`
  let resp_with_err = result.try_recover(httpc.send(req), normalize_http_error)
  use resp <- result.try(resp_with_err)

  let get_content_encoding = fn(r) {
    response.get_header(r, "content-encoding")
    |> result.replace_error("no content-encoding")
  }

  let content_encoding = get_content_encoding(resp)

  case content_encoding {
    Ok("gzip") -> handle_gzip(resp)
    Ok(_) -> Ok(resp)
    Error(msg) -> Error(msg)
  }
}

fn handle_gzip(
  res: response.Response(String),
) -> Result(response.Response(String), String) {
  // TODO: inflate gzip response
  Ok(res)
}
