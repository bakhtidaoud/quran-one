import 'dart:ui';

/// Digit systems, per locale.
///
/// Urdu and Arabic use DIFFERENT codepoints: U+0660 versus U+06F0. They
/// look related and are not interchangeable. Rendering Arabic digits to an
/// Urdu reader is legible but visibly foreign, and it is the single most
/// common localisation bug in this app category.
enum NumeralSystem {
  latin('0123456789'),
  arabicIndic('\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669'),
  easternArabicIndic(
    '\u06f0\u06f1\u06f2\u06f3\u06f4\u06f5\u06f6\u06f7\u06f8\u06f9',
  );

  const NumeralSystem(this.digits);

  final String digits;

  static NumeralSystem forLocale(Locale locale) =>
      switch (locale.languageCode) {
        'ar' => NumeralSystem.arabicIndic,
        'ur' || 'fa' => NumeralSystem.easternArabicIndic,
        _ => NumeralSystem.latin,
      };

  String format(int value) {
    if (this == NumeralSystem.latin) return '$value';
    return value
        .toString()
        .split('')
        .map((c) {
          final index = int.tryParse(c);
          return index == null ? c : digits[index];
        })
        .join();
  }
}

/// The exception that proves the rule.
///
/// Ayah numbers inside the mushaf are ALWAYS Arabic-Indic, in every locale,
/// including English and French. They belong to the typographic tradition
/// of the text rather than to the UI. A French reader correctly sees the
/// Arabic-Indic number inside the end-of-ayah marker and a Latin number in
/// the bookmark list, and both are right.
String ayahMarker(int ayah) =>
    '\u06dd${NumeralSystem.arabicIndic.format(ayah)}';
