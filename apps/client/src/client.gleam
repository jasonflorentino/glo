import client_sdk/messages.{
  type Message, UserDecrementedCount, UserIncrementedCount,
}
import client_sdk/model.{type Model, Model, model_decoder, model_to_json}
import client_sdk/view
import gleam/json
import gleam/option
import gleam/result
import lustre
import lustre/effect.{type Effect}
import plinth/browser/document
import plinth/browser/element as p_element

pub fn main() -> Nil {
  let model_query_error =
    json.to_string(model_to_json(
      Model(..model.empty_state, error: option.Some("error reading model")),
    ))
  let model_parse_error =
    Model(..model.empty_state, error: option.Some("error parsing model"))

  let json =
    document.query_selector("#model")
    |> result.map(p_element.inner_text)
    |> result.unwrap(model_query_error)

  let model =
    json.parse(json, model_decoder())
    |> result.unwrap(model_parse_error)

  let app = lustre.application(init, update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", model)

  Nil
}

fn init(initial_state: Model) -> #(Model, Effect(Message)) {
  let model = initial_state
  #(model, effect.none())
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserDecrementedCount -> #(
      Model(..model, count: model.count - 1),
      effect.none(),
    )
    UserIncrementedCount -> #(
      Model(..model, count: model.count + 1),
      effect.none(),
    )
  }
}
