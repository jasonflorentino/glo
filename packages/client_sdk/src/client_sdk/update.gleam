import client_sdk/messages.{
  type Message, ComputerUpdatedFrom, FetchTimetableError, RuntimeError,
  ServerReturnedTimetable, UserChangedFrom, UserPressedFetch,
}
import client_sdk/model.{type Model, Model}
import gleam/option.{None, Some}
import go_api/stops
import go_api/timetable
import lustre/effect.{type Effect}
import rsvp

pub fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  echo message
  case message {
    ComputerUpdatedFrom(from_stop, to_stop, to_stop_options) -> #(
      Model(..model, from_stop:, to_stop:, to_stop_options:),
      effect.none(),
    )
    UserChangedFrom(from) -> handle_user_changed_from(model, from)
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
    Ok(from_stop) -> {
      case from_stop == model.from_stop {
        True -> #(model, effect.none())
        False -> {
          let to_stop_options = stops.get_sister_stops(from_stop)
          let keep_current_to = case to_stop_options, model.to_stop {
            Some(line), Some(to) -> stops.line_has_stop(line, to)
            _, _ -> False
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
    Error(msg) -> #(Model(..model, error: Some(msg)), effect.none())
  }
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
