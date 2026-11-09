import client_sdk/components/form.{form_view}
import client_sdk/components/timetable.{timetable_view}
import client_sdk/messages.{type Message, UserPressedFetch}
import client_sdk/model.{type Model}
import gleam/json
import gleam/option.{None, Some}
import go_api/timetable as go_timetable
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
      form_view(model),
      html.section(
        [attribute.class("mt-4 sm:mt-6 md:mt-8")],
        timetable_view(model),
      ),
    ]),
    html.pre(
      [
        attribute.class("text-red-500"),
        attribute.style("white-space", "pre-wrap"),
      ],
      [
        html.text(case model.timetable {
          Some(tt) -> tt |> go_timetable.to_json |> json.to_string
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
