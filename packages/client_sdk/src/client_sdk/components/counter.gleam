import client_sdk/messages.{type Message}
import gleam/int
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn component(count: Int) -> Element(Message) {
  html.div([attribute.class("flex flex-col gap-1")], [])
}
