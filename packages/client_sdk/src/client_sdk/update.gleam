import client_sdk/messages.{
  type Message, ComputerUpdatedFrom, FetchTimetableError, RuntimeError,
  ServerReturnedTimetable, UserChangedFrom, UserChangedTo, UserPressedFetch,
}
import client_sdk/model.{type Model, Model}
import gleam/list
import gleam/option.{None, Some}
import gleam/uri
import go_api/stops.{type Stop, UnionStation}
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
      let to_stop_options =
        from_stop
        |> stops.get_sister_stops
        |> option.map(list.sort(_, stops.compare))

      case model.from_stop {
        // No existing FROM: write in options with no TO
        None -> {
          #(
            Model(
              ..model,
              timetable: None,
              from_stop: Some(from_stop),
              to_stop: None,
              to_stop_options:,
            ),
            effect.none(),
          )
        }
        // FROM already exists
        Some(curr_from) -> {
          case from_stop == curr_from {
            True -> noop(model)
            False -> {
              let keep_current_to = case
                from_stop,
                to_stop_options,
                model.to_stop
              {
                UnionStation, _, _ -> False
                _, Some(line), Some(to) ->
                  stops.line_has_stop(line, to) && to != UnionStation
                _, _, _ -> False
              }
              // TODO: fetch if route is changed!
              let to_stop = case keep_current_to {
                True -> model.to_stop
                False -> None
              }
              #(
                Model(
                  ..model,
                  timetable: None,
                  from_stop: Some(from_stop),
                  to_stop:,
                  to_stop_options:,
                ),
                effect.none(),
              )
            }
          }
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
      case model.from_stop, model.to_stop {
        None, _ -> {
          // wtf? FROM wasn't already set? 
          noop(model)
        }
        // No current TO
        Some(from_stop), None -> {
          let to_stop_options =
            stops.get_stop_options(Some(from_stop), Some(to_stop))
            |> option.map(list.sort(_, stops.compare))
          #(
            Model(..model, to_stop: Some(to_stop), to_stop_options:),
            handle_user_changed_to_fetch(from_stop, to_stop),
          )
        }
        // TO is set already
        Some(from_stop), Some(curr_to) -> {
          case curr_to == to_stop {
            True -> noop(model)
            False -> {
              let to_stop_options =
                stops.get_stop_options(Some(from_stop), Some(to_stop))
                |> option.map(list.sort(_, stops.compare))
              #(
                Model(..model, to_stop: Some(to_stop), to_stop_options:),
                handle_user_changed_to_fetch(from_stop, to_stop),
              )
            }
          }
        }
      }
    }
  }
}

fn handle_user_changed_to_fetch(from: Stop, to: Stop) -> Effect(Message) {
  let query_string =
    uri.query_to_string([
      #("from", from |> stops.to_code),
      #("to", to |> stops.to_code),
    ])
  effect.batch([
    modem.push("/", Some(query_string), None),
    rsvp.get(
      "/api/timetable?" <> query_string,
      rsvp.expect_json(timetable.decoder_json(), fn(res) {
        case res {
          Ok(timetable) -> ServerReturnedTimetable(timetable)
          Error(err) -> FetchTimetableError(string_from_rsvp_error(err))
        }
      }),
    ),
  ])
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
