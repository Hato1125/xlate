pub type Language {
  Japanese
  English
  Chinese
  Korean
  French
  German
  Spanish
  Italian
  Portuguese
  Russian
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

pub const all_languages = [
  Japanese,
  English,
  Chinese,
  Korean,
  French,
  German,
  Spanish,
  Italian,
  Portuguese,
  Russian,
]

pub fn language_label(language: Language) -> String {
  case language {
    Japanese -> "日本語"
    English -> "英語"
    Chinese -> "中国語"
    Korean -> "韓国語"
    French -> "フランス語"
    German -> "ドイツ語"
    Spanish -> "スペイン語"
    Italian -> "イタリア語"
    Portuguese -> "ポルトガル語"
    Russian -> "ロシア語"
  }
}

pub fn language_code(language: Language) -> String {
  case language {
    Japanese -> "ja"
    English -> "en"
    Chinese -> "zh"
    Korean -> "ko"
    French -> "fr"
    German -> "de"
    Spanish -> "es"
    Italian -> "it"
    Portuguese -> "pt"
    Russian -> "ru"
  }
}

/// The English name used when describing the language to the model.
pub fn language_name(language: Language) -> String {
  case language {
    Japanese -> "Japanese"
    English -> "English"
    Chinese -> "Simplified Chinese"
    Korean -> "Korean"
    French -> "French"
    German -> "German"
    Spanish -> "Spanish"
    Italian -> "Italian"
    Portuguese -> "Portuguese"
    Russian -> "Russian"
  }
}
