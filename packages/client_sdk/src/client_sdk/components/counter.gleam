import client_sdk/messages.{
  type Message, UserDecrementedCount, UserIncrementedCount,
}
import gleam/int
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn component(count: Int) -> Element(Message) {
  html.div([attribute.class("flex flex-col gap-1")], [
    html.text("Count: " <> int.to_string(count)),
    html.div([attribute.class("flex gap-0.5")], [
      html.button([event.on_click(UserIncrementedCount)], [html.text("+")]),
      html.button([event.on_click(UserDecrementedCount)], [html.text("-")]),
    ]),
  ])
}
