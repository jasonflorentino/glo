import client_sdk/messages.{type Message, UserChangedFrom}
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
            event.on_input(UserChangedFrom),
          ],
          stops.all() |> list.map(stop_to_option(_, Some(model.from_stop))),
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
            attribute.value(
              model.to_stop
              |> option.then(fn(c) { stops.to_code(c) |> Some })
              |> option.unwrap("None"),
            ),
          ],
          model.to_stop_options
            |> option.then(fn(stop_options) {
              list.map(stop_options, stop_to_option(_, model.to_stop))
              |> option.Some
            })
            |> option.unwrap([html.option([attribute.value("error")], "Error")]),
        ),
      ]),
    ]),
  ])
}

fn stop_to_option(s: stops.Stop, selected: option.Option(stops.Stop)) {
  html.option(
    [
      attribute.value(stops.to_code(s)),
      attribute.selected(case selected {
        Some(stop) -> s == stop
        None -> False
      }),
    ],
    stops.to_name(s),
  )
}
