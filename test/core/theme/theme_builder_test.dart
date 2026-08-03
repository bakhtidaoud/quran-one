import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/core/theme/theme.dart';

/// Relative luminance contrast, WCAG 2.2 definition.
double _contrast(Color a, Color b) {
  double lum(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  final l1 = lum(a);
  final l2 = lum(b);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const modes = QThemeMode.values;

  group('contrast floors', () {
    for (final mode in modes) {
      test('$mode holds 12:1 on Quranic text', () {
        final reading = QReadingTheme.resolve(
          mode: mode,
          mushafSize: 26,
          translationSize: 17,
        );
        // Self-imposed AAA on scripture. This is the one place the product
        // exceeds WCAG AA on purpose.
        expect(_contrast(reading.ink, reading.canvas), greaterThanOrEqualTo(12));
      });

      test('$mode holds 5.5:1 on body text', () {
        final theme = buildTheme(
          QThemeInput(mode: mode, locale: const Locale('en')),
        );
        final scheme = theme.colorScheme;
        expect(
          _contrast(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(5.5),
        );
      });
    }
  });

  test('AMOLED never uses pure white ink', () {
    final reading = QReadingTheme.resolve(
      mode: QThemeMode.amoled,
      mushafSize: 26,
      translationSize: 17,
    );
    // Pure white on true black haloes and fatigues the eye during long
    // reading sessions.
    expect(reading.ink, isNot(const Color(0xFFFFFFFF)));
    expect(reading.canvas, const Color(0xFF000000));
  });

  test('Arabic locales never receive letter spacing', () {
    final theme = buildTheme(
      const QThemeInput(mode: QThemeMode.light, locale: Locale('ar')),
    );
    // Arabic is a connected script. Any tracking breaks the joins.
    for (final style in [
      theme.textTheme.bodyLarge,
      theme.textTheme.titleMedium,
      theme.textTheme.labelSmall,
    ]) {
      expect(style!.letterSpacing ?? 0, 0);
    }
  });

  test('reduced motion clamps every duration to 150ms', () {
    final theme = buildTheme(
      const QThemeInput(
        mode: QThemeMode.light,
        locale: Locale('en'),
        reduceMotion: true,
      ),
    );
    final shape = theme.extension<QShapeMotion>()!;
    expect(shape.duration(QShapeMotion.long).inMilliseconds, 150);
    // Clamped, not zeroed: an instant state change is disorienting, a fast
    // one is not.
    expect(shape.duration(QShapeMotion.instant).inMilliseconds, 50);
  });

  test('theme input has value equality so the theme can be memoised', () {
    const a = QThemeInput(mode: QThemeMode.dark, locale: Locale('en'));
    const b = QThemeInput(mode: QThemeMode.dark, locale: Locale('en'));
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
