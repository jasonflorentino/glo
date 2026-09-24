import client_sdk/messages.{type Message, UserPressedFetch}
import client_sdk/model.{type Model}
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import go_api/timetable
import go_api/trip
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn view(model: Model) -> Element(Message) {
  html.div([], [
    html.h1([], [html.text("Hello World!")]),
    html.div([], [
      html.button([event.on_click(UserPressedFetch)], [
        html.text("Fetch timetable"),
      ]),
    ]),
    html.div([], timetable_view(model.timetable)),
    html.pre(
      [
        attribute.class("text-red-500"),
        attribute.style("white-space", "pre-wrap"),
      ],
      [
        html.text(case model.timetable {
          Some(tt) -> tt |> timetable.to_json |> json.to_string
          None -> "error"
        }),
      ],
    ),
    case model.error {
      option.None -> element.none()
      option.Some(error) ->
        html.div([attribute.class("text-red-400")], [html.text(error)])
    },
  ])
}

fn timetable_view(
  timetable: Option(timetable.Timetable),
) -> List(Element(Message)) {
  case timetable {
    Some(timetable) -> {
      [
        html.div([], [
          html.text(timetable.date),
        ]),
        ..list.map(timetable.trips, trip_view)
      ]
    }
    None -> [element.none()]
  }
}

fn trip_view(trip: trip.Trip) -> Element(Message) {
  html.div([attribute.class("flex justify-between mt-1 pb-1 border-b")], [
    html.div([attribute.class("flex flex-col")], [
      html.div([], [html.text("DEPARTS")]),
      html.div([], [html.text(trip.departure_time_display)]),
    ]),
    html.div([attribute.class("flex flex-col")], [
      html.div([], [html.text("TRAVELS")]),
      html.div([], [html.text(int.to_string(trip.duration_minutes))]),
    ]),
    html.div([attribute.class("flex flex-col")], [
      html.div([], [html.text("ARRIVES")]),
      html.div([], [html.text(trip.arrival_time_display)]),
    ]),
  ])
}
