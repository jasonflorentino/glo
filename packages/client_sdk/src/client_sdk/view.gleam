import gleam/json
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

import client_sdk/components/footer_actions
import client_sdk/components/form.{form_view}
import client_sdk/components/page_footer.{page_footer}
import client_sdk/components/timetable.{timetable_view}
import client_sdk/messages.{type Message}
import client_sdk/model.{type Model}

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
          [html.text("🚆 GloTrainSchedule")],
        ),
      ],
    ),
    html.main([attribute.class("p-4 min-h-svh")], [
      form_view(model),
      html.section(
        [attribute.class("mt-4 sm:mt-6 md:mt-8")],
        timetable_view(model),
      ),
      footer_actions.footer_actions(model),
    ]),
    page_footer(),
    html.h2(
      [
        attribute.class("text-4xl text-gray-200"),
      ],
      [html.text("Debug")],
    ),
    html.pre(
      [
        attribute.class("bg-gray-900 text-gray-200"),
        attribute.style("white-space", "pre-wrap"),
        attribute.style("overflow-wrap", "break-word"),
      ],
      [
        html.text(model |> model.model_to_json |> json.to_string),
      ],
    ),
    case model.error {
      option.None -> element.none()
      option.Some(error) ->
        html.div([attribute.class("text-red-400")], [html.text(error)])
    },
  ])
}
