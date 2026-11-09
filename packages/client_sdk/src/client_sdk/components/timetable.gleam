import client_sdk/messages.{type Message}
import client_sdk/model.{type Model}
import common/util
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import go_api/trip
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn timetable_view(model: Model) -> List(Element(Message)) {
  case model.timetable {
    Some(timetable) -> {
      [
        html.div([attribute.class("flex gap-2 items-baseline")], [
          html.h2(
            [
              attribute.class(
                "text-xl text-green-300 font-bold sm:text-2xl md:text-3xl",
              ),
            ],
            [
              html.text("Trips"),
            ],
          ),
          html.span([attribute.class("ml-auto md:ml-0")], [
            html.text(timetable.service_name),
            html.text(" – "),
            html.text(timetable.date),
          ]),
        ]),
        html.div([attribute.class("mt-2")], [
          html.ol([], list.map(timetable.trips, trip_view)),
        ]),
      ]
    }
    None -> [element.none()]
  }
}

fn trip_view(trip: trip.Trip) -> Element(Message) {
  html.li(
    [
      attribute.class(
        "border-t border-green-100 grid grid-cols-7 sm:grid-cols-3 gap-2 pt-1 pb-5 departed",
      ),
    ],
    [
      html.div([attribute.class("flex flex-col col-span-3 sm:col-span-1")], [
        trip_heading("DEPARTS", "text-blue-200"),
        trip_number(trip.departure_time_display),
      ]),
      html.div([attribute.class("flex flex-col col-span-3 sm:col-span-1")], [
        trip_heading("TRAVELS", "text-green-300"),
        trip_number(util.time_str_from_minutes(trip.duration_minutes)),
      ]),
      html.div(
        [
          attribute.class(
            "flex flex-col col-span-2 sm:col-span-1 items-end sm:items-start",
          ),
        ],
        [
          trip_heading("ARRIVES", "text-red-200"),
          trip_number(trip.arrival_time_display),
        ],
      ),
    ],
  )
}

fn trip_heading(text: String, color: String) -> Element(Message) {
  html.span(
    [
      attribute.class(string.join(
        ["text-xs md:text-sm uppercase opacity-80 font-medium", color],
        " ",
      )),
    ],
    [html.text(text)],
  )
}

fn trip_number(text: String) -> Element(Message) {
  html.span([attribute.class("text-xl font-medium sm:text-2xl md:text-3xl")], [
    html.text(text),
  ])
}
