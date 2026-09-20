import common/components/counter
import common/messages.{type Message}
import common/model.{type Model}
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn view(model: Model) -> Element(Message) {
  html.div([], [
    html.h1([], [html.text("Hello World!")]),
    counter.component(model.count),
    case model.error {
      option.None -> element.none()
      option.Some(error) ->
        html.div([attribute.style("color", "red")], [html.text(error)])
    },
  ])
}
