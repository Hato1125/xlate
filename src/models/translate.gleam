pub type Language {
  Japanese
  English
}

pub type TranslateRequest {
  TranslateRequest(
    url: String,
    model: String,
    text: String,
    from: Language,
    to: Language,
  )
}

pub const all_languages = [Japanese, English]

pub fn language_label(language: Language) -> String {
  case language {
    Japanese -> "日本語"
    English -> "English"
  }
}

pub fn language_code(language: Language) -> String {
  case language {
    Japanese -> "ja"
    English -> "en"
  }
}
