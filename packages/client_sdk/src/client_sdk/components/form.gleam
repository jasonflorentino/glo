import client_sdk/messages.{type Message, UserChangedFrom, UserChangedTo}
import client_sdk/model.{type Model}
import gleam/list
import gleam/option.{None, Some}
import go_api/stops
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn form_view(model: Model) -> Element(Message) {
  html.form([attribute.class("flex flex-col gap-4 mt-2 sm:mt-4 md:mt-6")], [
    html.div([attribute.class("flex gap-4 flex-col sm:flex-row")], [
      // FROM
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
            attribute.value(model.from_stop |> stops.to_code),
            attribute.default_value(model.from_stop |> stops.to_code),
            event.on_change(UserChangedFrom),
          ],
          stops.all()
            |> list.map(stop_to_option(_, selected: Some(model.from_stop))),
        ),
      ]),

      // TO
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
            attribute.value(model.to_stop |> stop_code_or_none),
            attribute.default_value(model.to_stop |> stop_code_or_none),
            event.on_change(UserChangedTo),
          ],
          model.to_stop_options
            |> option.then(fn(stop_options) {
              list.map(stop_options, stop_to_option(_, selected: model.to_stop))
              |> with_empty_option(model)
              |> option.Some
            })
            |> option.unwrap([html.option([attribute.value("error")], "Error")]),
        ),
      ]),
    ]),
  ])
}

fn with_empty_option(
  options: List(Element(a)),
  model: Model,
) -> List(Element(a)) {
  case model.to_stop {
    None -> [
      html.option(
        [
          attribute.value(""),
          attribute.selected(True),
          attribute.disabled(True),
          attribute.hidden(True),
        ],
        "-- Choose a stop --",
      ),
      ..options
    ]
    Some(_) -> options
  }
}

fn stop_code_or_none(s: option.Option(stops.Stop)) -> String {
  s
  |> option.map(stops.to_code)
  |> option.unwrap("")
}

fn stop_to_option(s: stops.Stop, selected slct: option.Option(stops.Stop)) {
  html.option(
    [
      attribute.value(stops.to_code(s)),
      attribute.selected(case slct {
        Some(stop) -> s == stop
        None -> False
      }),
    ],
    stops.to_name(s),
  )
}
