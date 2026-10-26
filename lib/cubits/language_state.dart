enum AppLanguage {
  bm,
  en,
}

class LanguageState {
  const LanguageState({
    this.language = AppLanguage.bm,
  });

  final AppLanguage language;

  bool get isEnglish => language == AppLanguage.en;
  bool get isMalay => language == AppLanguage.bm;
  String get code => language == AppLanguage.en ? 'en' : 'bm';

  LanguageState copyWith({
    AppLanguage? language,
  }) {
    return LanguageState(
      language: language ?? this.language,
    );
  }
}

