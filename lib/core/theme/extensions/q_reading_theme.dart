import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/q_theme_mode.dart';
import 'package:quran_one/core/theme/typography/q_style.dart';

/// The reading surface has its own colour and type system.
///
/// It is deliberately not derived from ColorScheme: scripture holds a 12:1
/// contrast floor that the rest of the UI does not, and the canvas must stay
/// stable when the user changes the app accent.
@immutable
class QReadingTheme extends ThemeExtension<QReadingTheme> {
  const QReadingTheme({
    required this.canvas,
    required this.ink,
    required this.inkMuted,
    required this.mark,
    required this.rule,
    required this.mushaf,
    required this.translation,
    required this.transliteration,
    required this.tafsir,
    required this.verseNumber,
    required this.footnote,
  });

  final Color canvas;
  final Color ink;
  final Color inkMuted;

  /// Verse markers, sajdah signs, active highlight.
  final Color mark;
  final Color rule;

  final TextStyle mushaf;
  final TextStyle translation;
  final TextStyle transliteration;
  final TextStyle tafsir;
  final TextStyle verseNumber;
  final TextStyle footnote;

  static QReadingTheme resolve({
    required QThemeMode mode,
    required double mushafSize,
    required double translationSize,
  }) {
    final (canvas, ink, inkMuted, mark, rule) = switch (mode) {
      QThemeMode.light => (
          const Color(0xFFFBF8F3),
          const Color(0xFF16181C),
          const Color(0xFF5A5D63),
          const Color(0xFF1F4A3C),
          const Color(0xFFE6E0D6),
        ),
      QThemeMode.dark => (
          const Color(0xFF14161A),
          const Color(0xFFE4E1DC),
          const Color(0xFF9A9791),
          const Color(0xFF7FB8A2),
          const Color(0xFF262A30),
        ),
      QThemeMode.amoled => (
          const Color(0xFF000000),
          const Color(0xFFD9D6D1),
          const Color(0xFF8E8B86),
          const Color(0xFF7FB8A2),
          const Color(0xFF161616),
        ),
    };

    return QReadingTheme(
      canvas: canvas,
      ink: ink,
      inkMuted: inkMuted,
      mark: mark,
      rule: rule,
      mushaf: qStyle(
        face: QFonts.uthmanic,
        size: mushafSize,
        weight: FontWeight.w400,
        height: 2,
        color: ink,
      ),
      translation: qStyle(
        face: QFonts.literata,
        size: translationSize,
        weight: FontWeight.w400,
        height: 1.7,
        color: ink,
      ),
      transliteration: qStyle(
        face: QFonts.literata,
        size: translationSize - 2,
        weight: FontWeight.w400,
        height: 1.6,
        color: inkMuted,
      ),
      tafsir: qStyle(
        face: QFonts.literata,
        size: translationSize - 1,
        weight: FontWeight.w400,
        height: 1.75,
        color: ink,
      ),
      // U+06DD end-of-ayah marker, sized relative to the Arabic body.
      verseNumber: qStyle(
        face: QFonts.uthmanic,
        size: mushafSize * 0.58,
        weight: FontWeight.w400,
        height: 1,
        color: mark,
      ),
      footnote: qStyle(
        face: QFonts.literata,
        size: 13,
        weight: FontWeight.w400,
        height: 1.55,
        color: inkMuted,
      ),
    );
  }

  @override
  QReadingTheme copyWith({
    Color? canvas,
    Color? ink,
    Color? inkMuted,
    Color? mark,
    Color? rule,
    TextStyle? mushaf,
    TextStyle? translation,
    TextStyle? transliteration,
    TextStyle? tafsir,
    TextStyle? verseNumber,
    TextStyle? footnote,
  }) =>
      QReadingTheme(
        canvas: canvas ?? this.canvas,
        ink: ink ?? this.ink,
        inkMuted: inkMuted ?? this.inkMuted,
        mark: mark ?? this.mark,
        rule: rule ?? this.rule,
        mushaf: mushaf ?? this.mushaf,
        translation: translation ?? this.translation,
        transliteration: transliteration ?? this.transliteration,
        tafsir: tafsir ?? this.tafsir,
        verseNumber: verseNumber ?? this.verseNumber,
        footnote: footnote ?? this.footnote,
      );

  @override
  QReadingTheme lerp(ThemeExtension<QReadingTheme>? other, double t) {
    if (other is! QReadingTheme) return this;
    return QReadingTheme(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      mark: Color.lerp(mark, other.mark, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      mushaf: TextStyle.lerp(mushaf, other.mushaf, t)!,
      translation: TextStyle.lerp(translation, other.translation, t)!,
      transliteration:
          TextStyle.lerp(transliteration, other.transliteration, t)!,
      tafsir: TextStyle.lerp(tafsir, other.tafsir, t)!,
      verseNumber: TextStyle.lerp(verseNumber, other.verseNumber, t)!,
      footnote: TextStyle.lerp(footnote, other.footnote, t)!,
    );
  }
}
