import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/language_cubit.dart';
import '../cubits/language_state.dart';

extension TranslationExtension on BuildContext {
  LanguageState get languageState => watch<LanguageCubit>().state;
  bool get isEnglish => languageState.isEnglish;
  bool get isMalay => languageState.isMalay;

  /// Quick helper: returns [en] if English is active, otherwise [bm].
  String tr(String bm, String en) => isEnglish ? en : bm;
}

class AppTranslations {
  // ==========================================
  // DASS-21 QUESTIONS (Standard BM & EN)
  // ==========================================
  static const List<String> dassQuestionsBM = [
    'Saya rasa susah untuk bertenang',
    'Saya sedar mulut saya rasa kering',
    'Saya seolah-olah tidak dapat mengalami perasaan positif sama sekali',
    'Saya mengalami kesukaran bernafas (contohnya, bernafas terlalu cepat Tercungap-cungap walaupun tidak melakukan aktiviti fizikal)',
    'Saya rasa tidak bersemangat untuk memulakan sesuatu keadaan',
    'Saya cenderung bertindak secara berlebihan kepada sesuatu keadaan',
    'Saya pernah menggeletar (contohnya tangan)',
    'Saya rasa saya terlalu gelisah',
    'Saya risau akan berlaku keadaan di mana saya panik dan berkelakuan bodoh',
    'Saya rasa tidak ada yang saya harapkan (putus harapan)',
    'Saya dapati saya mudah resah',
    'Saya merasa sukar untuk relaks',
    'Saya rasa muram dan sedih',
    'Saya tidak boleh terima apa jua yang menghalangi saya daripada meneruskan apa yang saya sedang lakukan',
    'Saya rasa hampir panik',
    'Saya tidak bersemangat langsung',
    'Saya rasa diri saya tidak berharga',
    'Saya mudah tersinggung',
    'Walaupun saya tidak melakukan aktiviti fizikal, saya sedar akan debaran Jantung saya (contoh: degupan jantung lebih cepat)',
    'Saya rasa takut tanpa sebab',
    'Saya rasa hidup ini tidak beerti lagi',
  ];

  static const List<String> dassQuestionsEN = [
    'I found it hard to wind down',
    'I was aware of dryness of my mouth',
    'I couldn\'t seem to experience any positive feeling at all',
    'I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion)',
    'I found it difficult to work up the initiative to do things',
    'I tended to over-react to situations',
    'I experienced trembling (e.g. in the hands)',
    'I felt that I was using a lot of nervous energy',
    'I was worried about situations in which I might panic and make a fool of myself',
    'I felt that I had nothing to look forward to',
    'I found myself getting agitated',
    'I found it difficult to relax',
    'I felt down-hearted and blue',
    'I was intolerant of anything that kept me from getting on with what I was doing',
    'I felt I was close to panic',
    'I was unable to become enthusiastic about anything',
    'I felt I wasn\'t worth much as a person',
    'I felt that I was rather touchy',
    'I was aware of the action of my heart in the absence of physical exertion (e.g. sense of heart rate increase, heart missing a beat)',
    'I felt scared without any good reason',
    'I felt that life was meaningless',
  ];

  static List<String> getDassQuestions(bool isEnglish) =>
      isEnglish ? dassQuestionsEN : dassQuestionsBM;

  static const Map<int, String> dassScalesBM = {
    0: 'Tidak pernah sama sekali',
    1: 'Jarang',
    2: 'Kerap',
    3: 'Sangat kerap',
  };

  static const Map<int, String> dassScalesEN = {
    0: 'Did not apply to me at all',
    1: 'Applied to me to some degree',
    2: 'Applied to me a considerable degree',
    3: 'Applied to me very much',
  };

  static Map<int, String> getDassScales(bool isEnglish) =>
      isEnglish ? dassScalesEN : dassScalesBM;

  // ==========================================
  // 10B METHODS TRANSLATIONS
  // ==========================================
  static const Map<String, String> methodNamesEN = {
    'Bertenang': 'Calm Down',
    'Bernafas Dengan Dalam': 'Deep Breathing',
    'Berkata "Relakslah"': 'Say "Relax"',
    'Beribadat': 'Worship & Pray',
    'Bercakap Dengan Seseorang': 'Talk to Someone',
    'Berurut': 'Massage',
    'Berehat & Mendengar Muzik': 'Rest & Listen to Music',
    'Berehat dan Mendengar Muzik': 'Rest and Listen to Music',
    'Beriadah': 'Recreation & Outing',
    'Bersenam': 'Exercise',
    'Berfikiran Positif': 'Think Positively',
    'Keseluruhan Teknik 10B': 'All 10B Techniques',
  };

  static String getMethodName(String bmName, bool isEnglish) {
    if (!isEnglish) return bmName;
    return methodNamesEN[bmName] ?? bmName;
  }
}

