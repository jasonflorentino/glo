import client_sdk/messages.{
  type Message, ComputerUpdatedFrom, FetchTimetableError, RuntimeError,
  ServerReturnedTimetable, UserChangedFrom, UserPressedFetch,
}
import client_sdk/model.{type Model, Model}
import gleam/option.{Some}
import go_api/stops
import go_api/timetable
import lustre/effect.{type Effect}
import rsvp

pub fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ComputerUpdatedFrom(to_stops) -> #(
      Model(..model, to_stop_options: to_stops),
      effect.none(),
    )
    UserChangedFrom(from) -> #(model, update_from(from))
    UserPressedFetch -> #(model, fetch_timetable())
    ServerReturnedTimetable(timetable) -> #(
      Model(..model, timetable: Some(timetable)),
      effect.none(),
    )
    FetchTimetableError(msg) -> #(model, effect.none())
    RuntimeError(msg) -> #(Model(..model, error: Some(msg)), effect.none())
  }
}

fn update_from(from: String) -> Effect(Message) {
  use dispatch <- effect.from
  let from = stops.from_string(from)

  case from {
    Ok(from_stop) -> {
      let to_stops = stops.get_sister_stops(from_stop)
      dispatch(ComputerUpdatedFrom(to_stops))
    }
    Error(msg) -> dispatch(RuntimeError(msg))
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
