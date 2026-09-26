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
    html.header(
      [attribute.class("p-2 sm:p-4 border-b-2 border-green-200 bg-green-600")],
      [
        html.h1(
          [
            attribute.class(
              "text-2xl pt-1 text-green-100 font-bold sm:text-3xl md:text-4xl",
            ),
          ],
          [html.text("🚆 Glo Train Schedule")],
        ),
      ],
    ),
    html.main([attribute.class("p-4 min-h-svh")], [
      html.div([], [
        html.button([event.on_click(UserPressedFetch)], [
          html.text("Fetch timetable"),
        ]),
      ]),
      html.section(
        [attribute.class("mt-4 sm:mt-6 md:mt-8")],
        timetable_view(model.timetable),
      ),
    ]),
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
        html.span(
          [
            attribute.class(
              "text-xs md:text-sm text-blue-200 uppercase opacity-80 font-medium",
            ),
          ],
          [html.text("DEPARTS")],
        ),
        html.span(
          [attribute.class("text-xl font-medium sm:text-2xl md:text-3xl")],
          [html.text(trip.departure_time_display)],
        ),
      ]),
      html.div([attribute.class("flex flex-col col-span-3 sm:col-span-1")], [
        html.span(
          [
            attribute.class(
              "text-xs md:text-sm text-green-300 uppercase opacity-80 font-medium",
            ),
          ],
          [html.text("TRAVELS")],
        ),
        html.span(
          [attribute.class("text-xl font-medium sm:text-2xl md:text-3xl")],
          [html.text(int.to_string(trip.duration_minutes))],
        ),
      ]),
      html.div(
        [
          attribute.class(
            "flex flex-col col-span-2 sm:col-span-1 items-end sm:items-start",
          ),
        ],
        [
          html.span(
            [
              attribute.class(
                "text-xs md:text-sm text-red-200 uppercase opacity-80 font-medium",
              ),
            ],
            [html.text("ARRIVES")],
          ),
          html.span(
            [attribute.class("text-xl font-medium sm:text-2xl md:text-3xl")],
            [html.text(trip.arrival_time_display)],
          ),
        ],
      ),
    ],
  )
}
