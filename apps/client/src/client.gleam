import common/model.{type Model, Model, model_decoder, model_to_json}
import gleam/int
import gleam/json
import gleam/option
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import plinth/browser/document
import plinth/browser/element as p_element

pub fn main() -> Nil {
  let model_query_error =
    json.to_string(
      model_to_json(Model(count: 0, error: option.Some("error reading model"))),
    )
  let model_parse_error =
    Model(count: 0, error: option.Some("error parsing model"))

  let json =
    document.query_selector("#model")
    |> result.map(p_element.inner_text)
    |> result.unwrap(model_query_error)

  let model =
    json.parse(json, model_decoder())
    |> result.unwrap(model_parse_error)

  echo model

  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", model)

  Nil
}

fn init(initial_state: Model) -> #(Model, Effect(Message)) {
  let model = initial_state
  #(model, effect.none())
}

type Message {
  UserDecrementedCount
  UserIncrementedCount
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

fn view(model: Model) -> Element(Message) {
  html.div([], [
    html.h1([], [html.text("Hello World!")]),
    view_counter(model.count),
    case model.error {
      option.None -> element.none()
      option.Some(error) ->
        html.div([attribute.style("color", "red")], [html.text(error)])
    },
  ])
}

fn view_counter(count: Int) -> Element(Message) {
  let root_styles = [
    #("display", "flex"),
    #("gap", "0.5rem"),
    #("flex-direction", "column"),
  ]
  let btn_box_styles = [#("display", "flex"), #("gap", "0.5rem")]
  html.div([attribute.styles(root_styles)], [
    html.text("Count: " <> int.to_string(count)),
    html.div([attribute.styles(btn_box_styles)], [
      html.button([event.on_click(UserIncrementedCount)], [html.text("+")]),
      html.button([event.on_click(UserDecrementedCount)], [html.text("-")]),
    ]),
  ])
}
