import gleam/javascript/promise
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/uri
import lustre/effect.{type Effect}
import modem
import plinth/browser/clipboard
import plinth/javascript/global
import rsvp

import client_sdk/messages.{
  type Message, ComputerUpdatedFrom, CopyFeedbackWindowEnded,
  FetchTimetableError, RuntimeError, ServerReturnedTimetable, UserChangedFrom,
  UserChangedTo, UserClickedCopy, UserPressedFetch,
}
import client_sdk/model.{type Model, Model}
import go_api/stops.{type Stop, UnionStation}
import go_api/timetable

pub fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  echo message
  case message {
    ComputerUpdatedFrom(from_stop, to_stop, to_stop_options) -> #(
      Model(..model, from_stop:, to_stop:, to_stop_options:),
      effect.none(),
    )
    CopyFeedbackWindowEnded(id) -> handle_copy_feedback_window_ended(model, id)
    UserChangedFrom(from) -> handle_user_changed_from(model, from)
    UserChangedTo(to) -> handle_user_changed_to(model, to)
    UserClickedCopy(id, text) -> handle_user_clicked_copy(model, id, text)
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

type UpdateHandler =
  fn() -> #(Model, Effect(Message))

type UpdateHandler1(a) =
  fn(a) -> #(Model, Effect(Message))

fn handle_copy_feedback_window_ended(
  model: Model,
  id: String,
) -> #(Model, Effect(Message)) {
  #(
    Model(
      ..model,
      copied_elem_ids: list.filter(model.copied_elem_ids, fn(i) { i != id }),
    ),
    effect.none(),
  )
}

fn handle_user_clicked_copy(
  model: Model,
  id: String,
  text: String,
) -> #(Model, Effect(Message)) {
  let copy_effect = effect.from(copy_to_clipboard(_, id, text))
  #(Model(..model, copied_elem_ids: [id, ..model.copied_elem_ids]), copy_effect)
}

fn handle_user_changed_from(
  model: Model,
  from: String,
) -> #(Model, Effect(Message)) {
  let from = stops.from_string(from)
  use from_stop <- with_parsed_stop(from, model)

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
        modem.replace("/", Some(query_string_from_stops(from_stop, None)), None),
      )
    }
    // FROM already exists
    Some(curr_from) -> {
      use <- when_from_stop_changed(from_stop != curr_from, model)
      let keep_current_to = case from_stop, to_stop_options, model.to_stop {
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
        modem.replace(
          "/",
          Some(query_string_from_stops(from_stop, to_stop)),
          None,
        ),
      )
    }
  }
}

fn handle_user_changed_to(
  model: Model,
  to: String,
) -> #(Model, Effect(Message)) {
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

fn query_string_from_stops(from: Stop, to: Option(Stop)) -> String {
  let from_pair = #("from", from |> stops.to_code)
  case to {
    None -> uri.query_to_string([from_pair])
    Some(to) -> uri.query_to_string([from_pair, #("to", to |> stops.to_code)])
  }
}

fn handle_user_changed_to_fetch(from: Stop, to: Stop) -> Effect(Message) {
  let query_string = query_string_from_stops(from, Some(to))
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
    rsvp.HttpError(resp) -> "rsvp:HttpError: " <> resp.body
    rsvp.JsonError(_) -> "rsvp:JsonError"
    rsvp.NetworkError -> "rsvp:NetworkError "
    rsvp.UnhandledResponse(_) -> "rsvpUnhandledResponse"
  }
}

fn copy_to_clipboard(
  dispatch: fn(Message) -> Nil,
  id: String,
  text: String,
) -> Nil {
  {
    use _ <- promise.map(clipboard.write_text(text))
    use <- global.set_timeout(1000)
    dispatch(CopyFeedbackWindowEnded(id))
  }
  Nil
}

fn with_parsed_stop(
  stop: Result(Stop, String),
  model: Model,
  cb: UpdateHandler1(Stop),
) {
  case stop {
    Error(msg) -> set_error(model, msg)
    Ok(stop) -> cb(stop)
  }
}

fn when_from_stop_changed(is_changed: Bool, model: Model, cb: UpdateHandler) {
  case is_changed {
    False -> noop(model)
    True -> cb()
  }
}
