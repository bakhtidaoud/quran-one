import 'package:flutter/material.dart';
import 'package:quran_one/core/storage/preferences.dart';
import 'package:quran_one/core/theme/theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

/// User-facing theme preference. Persisted synchronously because the
/// preferences instance is already resolved before the first frame.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  QThemeMode build() {
    final prefs = ref.watch(preferencesProvider);
    return QThemeMode.fromPreference(
      prefs.themeMode,
      amoled: prefs.amoled,
    );
  }

  Future<void> setMode(QThemeMode mode) async {
    final prefs = ref.read(preferencesProvider);
    await prefs.setThemeMode(mode == QThemeMode.light ? 'light' : 'dark');
    await prefs.setAmoled(value: mode == QThemeMode.amoled);
    state = mode;
  }

  /// Resolves 'system' against the platform brightness.
  QThemeMode resolveWithPlatform(Brightness platform) {
    final prefs = ref.read(preferencesProvider);
    if (prefs.themeMode != 'system') return state;
    if (platform == Brightness.light) return QThemeMode.light;
    return prefs.amoled ? QThemeMode.amoled : QThemeMode.dark;
  }
}

/// Reading text sizes. Kept separate from the theme mode so that dragging a
/// size slider does not rebuild the colour scheme.
@Riverpod(keepAlive: true)
class ReadingSizeController extends _$ReadingSizeController {
  @override
  ({double mushaf, double translation}) build() {
    final prefs = ref.watch(preferencesProvider);
    return (mushaf: prefs.mushafSize, translation: prefs.translationSize);
  }

  Future<void> setMushaf(double value) async {
    await ref.read(preferencesProvider).setMushafSize(value);
    state = (mushaf: value.clamp(18, 48), translation: state.translation);
  }

  Future<void> setTranslation(double value) async {
    await ref.read(preferencesProvider).setTranslationSize(value);
    state = (mushaf: state.mushaf, translation: value.clamp(14, 32));
  }
}

/// App locale. Null means follow the device.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    final code = ref.watch(preferencesProvider).localeCode;
    return code == null ? null : Locale(code);
  }

  Future<void> set(Locale? locale) async {
    await ref.read(preferencesProvider).setLocaleCode(locale?.languageCode);
    state = locale;
  }
}
