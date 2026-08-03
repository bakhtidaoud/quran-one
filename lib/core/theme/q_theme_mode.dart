/// Three first-class modes. AMOLED is not a dark-theme variant flag; it is a
/// separate mode with its own scheme, its own elevation strategy and its own
/// golden tests.
enum QThemeMode {
  light,
  dark,
  amoled;

  bool get isDark => this != QThemeMode.light;

  /// AMOLED draws separation with 1dp hairlines because tonal elevation is
  /// invisible on a true black surface.
  bool get usesHairlineElevation => this == QThemeMode.amoled;

  /// Shadows only read correctly on a light canvas.
  bool get usesShadows => this == QThemeMode.light;

  static QThemeMode fromPreference(String value, {required bool amoled}) =>
      switch (value) {
        'light' => QThemeMode.light,
        'dark' => amoled ? QThemeMode.amoled : QThemeMode.dark,
        _ => QThemeMode.light,
      };
}
