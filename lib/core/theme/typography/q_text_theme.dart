import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/typography/q_style.dart';

/// Builds the Material text theme, swapping the UI face by script.
///
/// Arabic locales get a taller baseline line height throughout, not just on
/// reading surfaces: labels and buttons clip diacritics otherwise.
TextTheme buildTextTheme({required bool isArabicLocale}) {
  final ui = isArabicLocale ? QFonts.plexArabic : QFonts.inter;
  final lift = isArabicLocale ? 0.15 : 0.0;

  return TextTheme(
    displayLarge: qStyle(
      face: ui,
      size: 57,
      weight: FontWeight.w400,
      height: 1.12 + lift,
    ),
    displayMedium: qStyle(
      face: ui,
      size: 45,
      weight: FontWeight.w400,
      height: 1.16 + lift,
    ),
    displaySmall: qStyle(
      face: ui,
      size: 36,
      weight: FontWeight.w400,
      height: 1.22 + lift,
    ),
    headlineLarge: qStyle(
      face: ui,
      size: 32,
      weight: FontWeight.w500,
      height: 1.25 + lift,
    ),
    headlineMedium: qStyle(
      face: ui,
      size: 28,
      weight: FontWeight.w500,
      height: 1.29 + lift,
    ),
    headlineSmall: qStyle(
      face: ui,
      size: 24,
      weight: FontWeight.w500,
      height: 1.33 + lift,
    ),
    titleLarge: qStyle(
      face: ui,
      size: 22,
      weight: FontWeight.w500,
      height: 1.27 + lift,
    ),
    titleMedium: qStyle(
      face: ui,
      size: 16,
      weight: FontWeight.w600,
      height: 1.5 + lift,
      letterSpacing: 0.15,
    ),
    titleSmall: qStyle(
      face: ui,
      size: 14,
      weight: FontWeight.w600,
      height: 1.43 + lift,
      letterSpacing: 0.1,
    ),
    bodyLarge: qStyle(
      face: ui,
      size: 16,
      weight: FontWeight.w400,
      height: 1.5 + lift,
      letterSpacing: 0.15,
    ),
    bodyMedium: qStyle(
      face: ui,
      size: 14,
      weight: FontWeight.w400,
      height: 1.43 + lift,
      letterSpacing: 0.25,
    ),
    bodySmall: qStyle(
      face: ui,
      size: 12,
      weight: FontWeight.w400,
      height: 1.33 + lift,
      letterSpacing: 0.4,
    ),
    labelLarge: qStyle(
      face: ui,
      size: 14,
      weight: FontWeight.w500,
      height: 1.43 + lift,
      letterSpacing: 0.1,
    ),
    labelMedium: qStyle(
      face: ui,
      size: 12,
      weight: FontWeight.w500,
      height: 1.33 + lift,
      letterSpacing: 0.5,
    ),
    labelSmall: qStyle(
      face: ui,
      size: 11,
      weight: FontWeight.w500,
      height: 1.45 + lift,
      letterSpacing: 0.5,
    ),
  );
}
