import 'package:flutter/foundation.dart';
import 'package:quran_one/core/theme/q_theme_mode.dart';

/// Tier 1 of four. Nothing here ever leaves the device.
///
/// Syncing theme is a bug that ships as a feature. Your phone is OLED and
/// wants AMOLED black; your tablet is LCD and turns that grey. A mushaf
/// at 26pt on a six-inch screen is unreadable at 26pt on a ten-inch one.
/// These are properties of a *screen*, not of a person, and pushing them
/// through sync makes every device worse than it was.
@immutable
class DevicePreferences {
  const DevicePreferences({
    this.themeMode = QThemeMode.light,
    this.amoled = false,
    this.dynamicColor = false,
    this.mushafSize = 26,
    this.translationSize = 17,
    this.reduceMotion = false,
  });

  final QThemeMode themeMode;
  final bool amoled;
  final bool dynamicColor;
  final double mushafSize;
  final double translationSize;
  final bool reduceMotion;

  // Backed by the SharedPreferences keys that already exist:
  // theme.mode, theme.amoled, theme.dynamicColor,
  // reading.mushafSize, reading.translationSize
}

/// Tier 3. Read from the platform, never persisted anywhere.
///
/// Country and timezone go stale the moment someone travels, and for an
/// app whose users routinely pray in one country and live in another,
/// stale is worse than absent. Timezone in particular must be live:
/// prayer notifications are scheduled on-device against the current zone,
/// so the server never needs to know it and therefore never stores it.
@immutable
class DerivedContext {
  const DerivedContext({
    required this.countryCode,
    required this.timeZone,
  });

  /// Exists only to look up prayer_region_default at first launch, so
  /// Morocco gets the Moroccan Ministry angles rather than Muslim World
  /// League. A hint on day one, irrelevant afterwards.
  final String countryCode;

  final String timeZone;
}
