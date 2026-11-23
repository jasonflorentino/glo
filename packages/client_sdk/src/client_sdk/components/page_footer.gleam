import gleam/option.{type Option, None}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

import client_sdk/messages.{type Message}

pub fn page_footer() -> Element(Message) {
  html.footer(
    [
      attribute.class(
        "p-6 bg-stone-950 flex flex-col gap-2 justify-center items-end sm:items-center text-sm md:text-base text-gray-400",
      ),
    ],
    [
      html.p([], [
        html.text("Made with 💚 in Hamilton"),
      ]),
      html.p([], [
        html.text("View source or file an issue on "),
        external_link(
          to: "https://github.com/jasonflorentino/glo/",
          class: None,
          children: [html.text("GitHub")],
        ),
      ]),
      html.p([], [
        html.text("Not affiliated with "),
        external_link(to: "https://www.gotransit.com/", class: None, children: [
          html.text("GO Transit"),
        ]),
      ]),
    ],
  )
}

pub fn external_link(
  to href: String,
  class class: Option(String),
  children children: List(Element(Message)),
) -> Element(Message) {
  html.a(
    [
      attribute.href(href),
      attribute.target("_blank"),
      attribute.rel("noreferrer"),
      attribute.class(option.unwrap(class, "underline text-green-300")),
    ],
    children,
  )
}
