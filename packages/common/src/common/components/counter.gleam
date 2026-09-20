import common/messages.{type Message, UserDecrementedCount, UserIncrementedCount}
import gleam/int
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn component(count: Int) -> Element(Message) {
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
