import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences.g.dart';

/// Typed wrapper over SharedPreferences.
///
/// Raw string keys never appear outside this file. Every key is declared
/// once as a private constant, which is what stops two features writing the
/// same key with different meanings.
class Preferences {
  const Preferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme.mode';
  static const _kAmoled = 'theme.amoled';
  static const _kDynamicColor = 'theme.dynamicColor';
  static const _kLocale = 'app.locale';
  static const _kMushafSize = 'reading.mushafSize';
  static const _kTranslationSize = 'reading.translationSize';
  static const _kCalculationMethod = 'prayer.calculationMethod';
  static const _kAsrMethod = 'prayer.asrMethod';
  static const _kOnboarded = 'app.onboarded';

  String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String v) => _prefs.setString(_kThemeMode, v);

  bool get amoled => _prefs.getBool(_kAmoled) ?? false;
  Future<void> setAmoled({required bool value}) =>
      _prefs.setBool(_kAmoled, value);

  bool get dynamicColor => _prefs.getBool(_kDynamicColor) ?? false;
  Future<void> setDynamicColor({required bool value}) =>
      _prefs.setBool(_kDynamicColor, value);

  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String? v) => v == null
      ? _prefs.remove(_kLocale)
      : _prefs.setString(_kLocale, v);

  /// Arabic mushaf text size. Range 18-48, default 26.
  double get mushafSize => _prefs.getDouble(_kMushafSize) ?? 26.0;
  Future<void> setMushafSize(double v) =>
      _prefs.setDouble(_kMushafSize, v.clamp(18.0, 48.0));

  /// Translation text size. Range 14-32, default 17. Independent of the
  /// Arabic slider on purpose: the two scripts are read differently.
  double get translationSize => _prefs.getDouble(_kTranslationSize) ?? 17.0;
  Future<void> setTranslationSize(double v) =>
      _prefs.setDouble(_kTranslationSize, v.clamp(14.0, 32.0));

  String get calculationMethod =>
      _prefs.getString(_kCalculationMethod) ?? 'muslim_world_league';
  Future<void> setCalculationMethod(String v) =>
      _prefs.setString(_kCalculationMethod, v);

  String get asrMethod => _prefs.getString(_kAsrMethod) ?? 'standard';
  Future<void> setAsrMethod(String v) => _prefs.setString(_kAsrMethod, v);

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded({required bool value}) =>
      _prefs.setBool(_kOnboarded, value);
}

/// Root provider. Overridden in bootstrap.
@Riverpod(keepAlive: true)
Preferences preferences(Ref ref) =>
    throw UnimplementedError('preferencesProvider must be overridden');
