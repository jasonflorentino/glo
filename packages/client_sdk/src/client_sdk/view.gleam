import client_sdk/components/counter
import client_sdk/messages.{type Message}
import client_sdk/model.{type Model}
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

//     html.div([], []),

pub fn view(model: Model) -> Element(Message) {
  html.div([], [
    html.h1([], [html.text("Hello World!")]),
    counter.component(model.count),
    html.pre(
      [
        attribute.class("text-red-500"),
        attribute.style("white-space", "pre-wrap"),
      ],
      [
        html.text(model.timetable),
      ],
    ),
    case model.error {
      option.None -> element.none()
      option.Some(error) ->
        html.div([attribute.class("text-red-400")], [html.text(error)])
    },
  ])
}
