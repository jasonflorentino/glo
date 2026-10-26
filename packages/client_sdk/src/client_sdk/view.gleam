import client_sdk/messages.{type Message, UserPressedFetch}
import client_sdk/model.{type Model}
import common/util
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
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
      form_view(),
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

fn form_view() -> Element(Message) {
  html.form([attribute.class("flex flex-col gap-4 mt-2 sm:mt-4 md:mt-6")], [
    html.div([attribute.class("flex gap-4 flex-col sm:flex-row")], [
      html.div([attribute.class("flex items-center w-full")], [
        html.label(
          [
            attribute.for("fromStop"),
            attribute.class("block min-w-12 md:text-lg"),
          ],
          [html.text("From")],
        ),
        html.select(
          [
            attribute.id("fromStop"),
            attribute.name("from"),
            attribute.class(
              "p-3 block h-12 md:h-14 rounded text-lg font-medium md:text-2xl w-full text-blue-200 border border-stone-600 bg-stone-950 focus:outline-none focus:ring-2 focus:ring-green-500",
            ),
          ],
          [
            // TODO: Add all stops 
            html.option([attribute.value("AC")], "Action GO"),
            html.option(
              [attribute.value("UN"), attribute.selected(True)],
              "Union Station GO",
            ),
            html.option([attribute.value("WR")], "West Harbour GO"),
          ],
        ),
      ]),
      html.div([attribute.class("flex items-center w-full")], [
        html.label(
          [
            attribute.for("toStop"),
            attribute.class("block min-w-12 md:text-lg drop-shadow-md"),
          ],
          [html.text("To")],
        ),
        html.select(
          [
            attribute.id("toStop"),
            attribute.name("to"),
            attribute.class(
              "p-3 block h-12 md:h-14 rounded text-lg font-medium md:text-2xl w-full text-red-200 border border-stone-600 bg-stone-950 focus:outline-none focus:ring-2 focus:ring-green-500",
            ),
          ],
          [
            // TODO: Show only sisters stops for the selected From Stop 
            html.option([attribute.value("AC")], "Action GO"),
            html.option(
              [
                attribute.value("UN"),
              ],
              "Union Station GO",
            ),
            html.option(
              [attribute.value("WR"), attribute.selected(True)],
              "West Harbour GO",
            ),
          ],
        ),
      ]),
    ]),
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
