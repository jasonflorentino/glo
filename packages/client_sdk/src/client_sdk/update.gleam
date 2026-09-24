import client_sdk/messages.{
  type Message, FetchTimetableError, ServerReturnedTimetable,
  UserDecrementedCount, UserIncrementedCount, UserPressedFetch,
}
import client_sdk/model.{type Model, Model}
import gleam/option.{Some}
import go_api/timetable
import lustre/effect.{type Effect}
import rsvp

pub fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserDecrementedCount -> #(
      Model(..model, count: model.count - 1),
      effect.none(),
    )
    UserIncrementedCount -> #(
      Model(..model, count: model.count + 1),
      effect.none(),
    )
    UserPressedFetch -> #(model, fetch_timetable())
    ServerReturnedTimetable(timetable) -> #(
      Model(..model, timetable: Some(timetable)),
      effect.none(),
    )
    FetchTimetableError(msg) -> #(model, effect.none())
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
