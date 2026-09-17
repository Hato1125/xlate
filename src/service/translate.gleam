import gleam/dynamic/decode
import gleam/json
import lustre/effect.{type Effect}
import rsvp

import models/translate.{type TranslateRequest, language_name}

pub fn translate(
  request: TranslateRequest,
  on_done: fn(Result(String, rsvp.Error(String))) -> msg,
) -> Effect(msg) {
  let prompt =
    "Please translatet the provided text from "
    <> language_name(request.from)
    <> " to "
    <> language_name(request.to)
    <> ". Reply with the translation only.\n\n"
    <> request.text

  let body =
    json.object([
      #("model", json.string(request.model)),
      #(
        "messages",
        json.preprocessed_array([
          json.object([
            #("role", json.string("user")),
            #("content", json.string(prompt)),
          ]),
        ]),
      ),
      #("stream", json.bool(False)),
    ])

  let decoder = {
    use content <- decode.subfield(["message", "content"], decode.string)
    decode.success(content)
  }

  rsvp.post(
    request.url <> "/api/chat",
    body,
    rsvp.expect_json(decoder, on_done),
  )
}
