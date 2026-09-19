import gleam/int
import gleam/option.{type Option}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", 0)

  Nil
}

type Model {
  Model(count: Int, error: Option(String))
}

fn init(initial_count: Int) -> #(Model, Effect(Message)) {
  let model = Model(count: initial_count, error: option.None)
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
