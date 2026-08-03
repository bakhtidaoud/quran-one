import 'dart:ui';

import 'package:quran_one/core/i18n/numerals.dart';

/// Everything that varies by locale and is not a translated string.
///
/// Kept in one table because direction, numerals, font and line height are
/// not independent choices: getting Urdu right means Nastaliq AND eastern
/// digits AND a 2.0 line height, and picking two of the three produces
/// something that looks broken to the only people who would notice.
class LocaleMeta {
  const LocaleMeta({
    required this.locale,
    required this.nativeName,
    required this.direction,
    required this.numerals,
    required this.fontFamily,
    this.lineHeightFloor = 1.5,
    this.isComplete = true,
  });

  final Locale locale;
  final String nativeName;
  final TextDirection direction;
  final NumeralSystem numerals;
  final String fontFamily;

  /// Minimum line height. Scripts with deep descenders collide below it.
  final double lineHeightFloor;

  /// False when the catalogue is partial. A locale offered in Settings
  /// that falls back to English half the time is worse than one that is
  /// not offered yet.
  final bool isComplete;

  bool get isRtl => direction == TextDirection.rtl;

  static const supported = <LocaleMeta>[
    LocaleMeta(
      locale: Locale('en'),
      nativeName: 'English',
      direction: TextDirection.ltr,
      numerals: NumeralSystem.latin,
      fontFamily: 'Inter',
    ),
    LocaleMeta(
      locale: Locale('ar'),
      nativeName: '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
      direction: TextDirection.rtl,
      numerals: NumeralSystem.arabicIndic,
      fontFamily: 'IBMPlexSansArabic',
      lineHeightFloor: 1.70,
      isComplete: false,
    ),
    LocaleMeta(
      locale: Locale('fr'),
      nativeName: 'Fran\u00e7ais',
      direction: TextDirection.ltr,
      numerals: NumeralSystem.latin,
      fontFamily: 'Inter',
      isComplete: false,
    ),
    LocaleMeta(
      locale: Locale('tr'),
      nativeName: 'T\u00fcrk\u00e7e',
      direction: TextDirection.ltr,
      numerals: NumeralSystem.latin,
      fontFamily: 'Inter',
      isComplete: false,
    ),
    LocaleMeta(
      locale: Locale('id'),
      nativeName: 'Bahasa Indonesia',
      direction: TextDirection.ltr,
      numerals: NumeralSystem.latin,
      fontFamily: 'Inter',
      isComplete: false,
    ),
    LocaleMeta(
      locale: Locale('ur'),
      nativeName: '\u0627\u0631\u062f\u0648',
      direction: TextDirection.rtl,
      numerals: NumeralSystem.easternArabicIndic,
      // Nastaliq, not Naskh. Urdu set in Naskh is readable the way English
      // set in Fraktur is readable.
      fontFamily: 'NotoNastaliqUrdu',
      // Nastaliq descends steeply across the baseline. Below 2.0 the
      // strokes of one line collide with the line beneath it.
      lineHeightFloor: 2.00,
      isComplete: false,
    ),
  ];

  static LocaleMeta of(Locale locale) => supported.firstWhere(
        (m) => m.locale.languageCode == locale.languageCode,
        orElse: () => supported.first,
      );
}
