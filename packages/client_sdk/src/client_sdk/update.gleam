import client_sdk/messages.{
  type Message, ComputerUpdatedFrom, FetchTimetableError, RuntimeError,
  ServerReturnedTimetable, UserChangedFrom, UserChangedTo, UserPressedFetch,
}
import client_sdk/model.{type Model, Model}
import gleam/list
import gleam/option.{None, Some}
import gleam/uri
import go_api/stops.{UnionStation}
import go_api/timetable
import lustre/effect.{type Effect}
import modem
import rsvp

pub fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  echo message
  case message {
    ComputerUpdatedFrom(from_stop, to_stop, to_stop_options) -> #(
      Model(..model, from_stop:, to_stop:, to_stop_options:),
      effect.none(),
    )
    UserChangedFrom(from) -> handle_user_changed_from(model, from)
    UserChangedTo(to) -> handle_user_changed_to(model, to)
    UserPressedFetch -> #(model, fetch_timetable())
    ServerReturnedTimetable(timetable) -> #(
      Model(..model, timetable: Some(timetable)),
      effect.none(),
    )
    FetchTimetableError(msg) -> #(
      Model(..model, error: Some(msg)),
      effect.none(),
    )
    RuntimeError(msg) -> #(Model(..model, error: Some(msg)), effect.none())
  }
}

fn handle_user_changed_from(
  model: Model,
  from: String,
) -> #(Model, Effect(Message)) {
  let from = stops.from_string(from)

  case from {
    Error(msg) -> set_error(model, msg)
    Ok(from_stop) -> {
      case from_stop == model.from_stop {
        True -> noop(model)
        False -> {
          let to_stop_options =
            from_stop
            |> stops.get_sister_stops
            |> option.map(list.sort(_, stops.compare))
          let keep_current_to = case from_stop, to_stop_options, model.to_stop {
            UnionStation, _, _ -> False
            _, Some(line), Some(to) ->
              stops.line_has_stop(line, to) && to != UnionStation
            _, _, _ -> False
          }
          let to_stop = case keep_current_to {
            True -> model.to_stop
            False -> None
          }
          #(
            Model(..model, from_stop:, to_stop:, to_stop_options:),
            effect.none(),
          )
        }
      }
    }
  }
}

fn handle_user_changed_to(model: Model, to: String) -> #(Model, Effect(Message)) {
  let to = stops.from_string(to)
  case to {
    Error(msg) -> set_error(model, msg)
    Ok(to_stop) -> {
      let to_stop_options =
        to_stop
        |> stops.get_line_stops
        |> option.map(list.sort(_, stops.compare))
      let query_string =
        uri.query_to_string([
          #("from", model.from_stop |> stops.to_code),
          #("to", to_stop |> stops.to_code),
        ])
      case model.to_stop {
        Some(curr_to) -> {
          case curr_to == to_stop {
            True -> noop(model)
            False -> {
              #(
                Model(..model, to_stop: Some(to_stop), to_stop_options:),
                modem.push("/", Some(query_string), None),
              )
            }
          }
        }
        None -> {
          #(
            Model(..model, to_stop: Some(to_stop), to_stop_options:),
            modem.push("/", Some(query_string), None),
          )
        }
      }
    }
  }
}

fn noop(model: Model) -> #(Model, Effect(Message)) {
  #(model, effect.none())
}

fn set_error(model: Model, msg: String) -> #(Model, Effect(Message)) {
  #(Model(..model, error: Some(msg)), effect.none())
}

fn fetch_timetable() -> Effect(Message) {
  rsvp.get(
    "/api/timetable",
    rsvp.expect_json(timetable.decoder_json(), fn(res) {
      case res {
        Ok(timetable) -> ServerReturnedTimetable(timetable)
        Error(err) -> FetchTimetableError(string_from_rsvp_error(err))
      }
    }),
  )
}

fn string_from_rsvp_error(err: rsvp.Error(String)) -> String {
  case err {
    rsvp.BadBody -> "rsvp:BadBody"
    rsvp.BadUrl(str) -> "rsvp:BadUrl: " <> str
    rsvp.HttpError(_) -> "rsvp:HttpError"
    rsvp.JsonError(_) -> "rsvp:JsonError"
    rsvp.NetworkError -> "rsvp:NetworkError "
    rsvp.UnhandledResponse(_) -> "rsvpUnhandledResponse"
  }
}
