import gleam/option.{Some}
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

import client_sdk/messages.{type Message}
import client_sdk/model.{type Model}
import go_api/stops

pub fn footer_actions(model: Model) -> Element(Message) {
  use from, to <- with_trip_detail(model)
  html.div(
    [
      attribute.class(
        "fixed bottom-6 left-4 z-10 sm:bottom-8 sm:left-auto sm:right-6 lg:bottom-10 lg:right-8 flex gap-2",
      ),
    ],
    [
      html.div([], [
        html.a(
          [
            // TODO: include the date?
            attribute.href("/?" <> to_other_way_href(from, to)),
            attribute.class(
              "block pb-2 pt-3 px-3 text-green-100 text-base sm:text-lg font-medium rounded-full bg-green-600",
            ),
          ],
          [
            html.span([attribute.class("hidden sm:inline-block sm:pr-0.5")], [
              html.text("🔄"),
            ]),
            html.text(" Other Way "),
          ],
        ),
      ]),
    ],
  )
}

/// Only render when from_stop and to_stop exist
fn with_trip_detail(
  model: model.Model,
  render: fn(stops.Stop, stops.Stop) -> Element(Message),
) -> Element(Message) {
  case model.from_stop, model.to_stop {
    Some(from), Some(to) -> render(from, to)
    _, _ -> element.none()
  }
}

fn to_other_way_href(from: stops.Stop, to: stops.Stop) -> String {
  uri.query_to_string([
    #("from", to |> stops.to_code),
    #("to", from |> stops.to_code),
  ])
}
