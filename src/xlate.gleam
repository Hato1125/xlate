import gleam/list
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event
import rsvp

import models/translate.{
  type Language, English, Japanese, TranslateRequest, all_languages,
  language_code, language_label,
}
import service/translate as translate_service

pub type TextArea {
  TextArea(text: String, language: Language)
}

pub type SelectTarget {
  FromSelect
  ToSelect
}

pub type Model {
  Model(
    ip: String,
    from: TextArea,
    to: TextArea,
    open_select: Option(SelectTarget),
  )
}

pub type Message {
  Swap
  UserTypedFrom(String)
  UserTypedIp(String)
  UserToggledSelect(SelectTarget)
  SelectFromLanguage(Language)
  SelectToLanguage(Language)
  TranslationReceived(Result(String, rsvp.Error(String)))
}

fn init(_args) -> #(Model, Effect(Message)) {
  #(
    Model(
      ip: "http://127.0.0.1:11434",
      from: TextArea(text: "", language: Japanese),
      to: TextArea(text: "", language: English),
      open_select: None,
    ),
    effect.none(),
  )
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserTypedIp(ip) -> #(Model(..model, ip:), effect.none())

    Swap -> {
      let tmp = model.from.language

      #(
        Model(
          ..model,
          from: TextArea(..model.from, language: model.to.language),
          to: TextArea(..model.to, language: tmp),
        ),
        effect.none(),
      )
    }

    UserTypedFrom(text) -> {
      let model = Model(..model, from: TextArea(..model.from, text:))
      let request =
        TranslateRequest(
          url: model.ip,
          model: "translategemma:4b",
          text:,
          from: model.from.language,
          to: model.to.language,
        )
      #(model, translate_service.translate(request, TranslationReceived))
    }

    UserToggledSelect(target) -> {
      let open_select = case model.open_select {
        Some(current) if current == target -> None
        _ -> Some(target)
      }
      #(Model(..model, open_select:), effect.none())
    }

    SelectFromLanguage(language) -> #(
      Model(..model, from: TextArea(..model.from, language:), open_select: None),
      effect.none(),
    )

    SelectToLanguage(language) -> #(
      Model(..model, to: TextArea(..model.to, language:), open_select: None),
      effect.none(),
    )

    TranslationReceived(Ok(translated)) -> #(
      Model(..model, to: TextArea(..model.to, text: translated)),
      effect.none(),
    )

    TranslationReceived(Error(_)) -> #(model, effect.none())
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([attribute.class("p-4 flex flex-col gap-4")], [
    ip_field(model.ip),
    translate_panel(model),
  ])
}

fn ip_field(ip: String) -> Element(Message) {
  html.div([attribute.role("group"), attribute.class("field")], [
    html.label([attribute.for("ollama-url")], [html.text("Ollama URL")]),
    html.input([
      attribute.id("ollama-url"),
      attribute.type_("url"),
      attribute.placeholder("http://127.0.0.1:11434"),
      attribute.value(ip),
      event.on_input(UserTypedIp),
    ]),
  ])
}

fn translate_panel(model: Model) -> Element(Message) {
  html.div([attribute.class("flex flex-row gap-2")], [
    html.div([attribute.class("flex w-full flex-col gap-2")], [
      language_select(
        model,
        FromSelect,
        model.from.language,
        SelectFromLanguage,
      ),
      html.textarea(
        [
          attribute.class("textarea w-full"),
          attribute.rows(6),
          attribute.placeholder("FROM"),
          event.on_input(UserTypedFrom) |> event.debounce(500),
        ],
        model.from.text,
      ),
    ]),
    html.div([attribute.class("flex items-center")], [
      html.button(
        [
          attribute.class("btn"),
          attribute.attribute("data-variant", "outline"),
          attribute.attribute("data-size", "icon"),
          attribute.attribute("aria-label", "Swap languages"),
          event.on_click(Swap),
        ],
        [swap_icon()],
      ),
    ]),
    html.div([attribute.class("flex w-full flex-col gap-2")], [
      language_select(model, ToSelect, model.to.language, SelectToLanguage),
      html.textarea(
        [
          attribute.class("textarea w-full"),
          attribute.rows(6),
          attribute.placeholder("TO"),
          attribute.readonly(True),
        ],
        model.to.text,
      ),
    ]),
  ])
}

fn language_select(
  model: Model,
  target: SelectTarget,
  selected: Language,
  on_select: fn(Language) -> Message,
) -> Element(Message) {
  let is_open = model.open_select == Some(target)

  html.div([attribute.class("select")], [
    html.button(
      [
        attribute.type_("button"),
        attribute.aria_haspopup("listbox"),
        attribute.aria_expanded(is_open),
        event.on_click(UserToggledSelect(target)),
      ],
      [html.span([], [html.text(language_label(selected))]), chevron_icon()],
    ),
    html.div(
      [attribute.attribute("data-popover", ""), attribute.aria_hidden(!is_open)],
      [
        html.div(
          [
            attribute.role("listbox"),
            attribute.attribute("aria-orientation", "vertical"),
          ],
          list.map(all_languages, fn(language) {
            html.div(
              [
                attribute.role("option"),
                attribute.attribute("data-value", language_code(language)),
                attribute.aria_selected(language == selected),
                event.on_click(on_select(language)),
              ],
              [html.text(language_label(language))],
            )
          }),
        ),
      ],
    ),
  ])
}

fn swap_icon() -> Element(Message) {
  html.svg(
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("fill", "none"),
      attribute.attribute("stroke", "currentColor"),
      attribute.attribute("stroke-width", "2"),
      attribute.attribute("stroke-linecap", "round"),
      attribute.attribute("stroke-linejoin", "round"),
    ],
    [
      svg.path([attribute.attribute("d", "M8 3 4 7l4 4")]),
      svg.path([attribute.attribute("d", "M4 7h16")]),
      svg.path([attribute.attribute("d", "m16 21 4-4-4-4")]),
      svg.path([attribute.attribute("d", "M20 17H4")]),
    ],
  )
}

fn chevron_icon() -> Element(Message) {
  html.svg(
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("fill", "none"),
      attribute.attribute("stroke", "currentColor"),
      attribute.attribute("stroke-width", "2"),
      attribute.attribute("stroke-linecap", "round"),
      attribute.attribute("stroke-linejoin", "round"),
    ],
    [svg.path([attribute.attribute("d", "m6 9 6 6 6-6")])],
  )
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
