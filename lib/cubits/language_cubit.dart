import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const String _prefKey = 'app_language';

  LanguageCubit() : super(const LanguageState());

  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_prefKey);
      if (langCode == 'en') {
        emit(const LanguageState(language: AppLanguage.en));
      } else {
        emit(const LanguageState(language: AppLanguage.bm));
      }
    } catch (_) {
      emit(const LanguageState(language: AppLanguage.bm));
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state.language == language) return;
    emit(state.copyWith(language: language));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language == AppLanguage.en ? 'en' : 'bm');
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final nextLang = state.isEnglish ? AppLanguage.bm : AppLanguage.en;
    await setLanguage(nextLang);
  }
}

