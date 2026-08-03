# Quran One - Flutter Theme Architecture

Codename: Mizan
Material 3 - Clean Architecture - production reference implementation
Depends on: DESIGN_SYSTEM.md, COLOR_SYSTEM.md, TYPOGRAPHY_SYSTEM.md, MOTION_SYSTEM.md, ACCESSIBILITY.md

---

## 0. Five architectural decisions

**1. `ThemeData` is a pure function of an input record.** `buildTheme(QThemeInput)` has no side effects, reads no globals and touches no `BuildContext`. Every theme snapshot is testable without pumping a widget tree.

**2. Colour schemes are hand-authored constants, never `ColorScheme.fromSeed` at runtime.** Seeding is a design-time tool. At runtime it costs a HCT solve per theme build and produces tones we have already rejected: our floors (12:1 Quranic, 8:1 translation) are not reachable through Material's default tonal mapping.

**3. Everything not expressible in `ColorScheme` lives in a `ThemeExtension`.** Four of them.

**4. AMOLED is a first-class third mode**, not dark-with-a-black-background. It has its own elevation strategy (hairlines, not tonal overlays), its own ink (`#D9D6D1`, never `#FFFFFF`) and its own surface ramp.

**5. Component themes are exhaustive.** If a widget's appearance is not declared in `ThemeData`, someone will style it at the call site and the system stops being a system.

---

## 1. Folder structure

```
lib/
  core/theme/
    theme.dart                  # single public barrel
    q_theme_input.dart
    q_theme_builder.dart        # buildTheme() - the only ThemeData factory
    q_theme_mode.dart

    color/
      q_ref_colors.dart         # raw hex. Imported by exactly one file.
      q_color_schemes.dart
      q_dynamic_color.dart

    typography/
      q_font_face.dart
      q_style.dart              # qStyle() - the ONLY TextStyle factory
      q_text_theme.dart
      q_strut.dart

    extensions/
      q_semantic_colors.dart
      q_typography.dart
      q_reading_theme.dart
      q_shape_motion.dart

    components/
      q_button_themes.dart
      q_input_themes.dart
      q_surface_themes.dart
      q_navigation_themes.dart
      q_selection_themes.dart
      q_feedback_themes.dart

    elevation/
      q_elevation.dart

  presentation/theme/
    theme_controller.dart
    theme_scope.dart
```

### 1.1 Layering rule

| Layer | May import |
| --- | --- |
| `color/q_ref_colors.dart` | `dart:ui` only |
| `core/theme/**` | other `core/theme` files, Flutter |
| `presentation/theme/**` | `core/theme`, Riverpod, domain preferences |
| `features/**` | `core/theme/theme.dart` **only** |

Raw hex must never be reachable from feature code. An import lint enforces it.

---

## 2. Input record and mode

```dart
enum QThemeMode {
  light, dark, amoled;

  bool get isDark => this != QThemeMode.light;

  /// AMOLED uses hairline borders instead of tonal elevation overlays,
  /// because tonal shift is impossible against pure black.
  bool get usesHairlineElevation => this == QThemeMode.amoled;

  /// Shadows are a light-theme affordance only. On dark surfaces they
  /// read as smudges rather than depth.
  bool get usesShadows => this == QThemeMode.light;
}
```

```dart
@immutable
class QThemeInput {
  const QThemeInput({
    required this.mode,
    required this.locale,
    this.dynamicScheme,
    this.mushafSize = 26.0,
    this.translationSize = 17.0,
    this.reduceMotion = false,
  });

  final QThemeMode mode;
  final Locale locale;
  final ColorScheme? dynamicScheme;
  final double mushafSize;
  final double translationSize;
  final bool reduceMotion;

  bool get isArabicLocale => switch (locale.languageCode) {
        'ar' || 'fa' || 'ur' || 'ps' || 'sd' || 'ku' => true,
        _ => false,
      };

  @override
  bool operator ==(Object other) =>
      other is QThemeInput &&
      other.mode == mode &&
      other.locale == locale &&
      other.dynamicScheme == dynamicScheme &&
      other.mushafSize == mushafSize &&
      other.translationSize == translationSize &&
      other.reduceMotion == reduceMotion;

  @override
  int get hashCode => Object.hash(mode, locale, dynamicScheme,
      mushafSize, translationSize, reduceMotion);
}
```

Value equality is not cosmetic. It is what lets us memoise `buildTheme` and avoid rebuilding a genuinely expensive object on every frame while the reader size slider is dragged.

---

## 3. Reference colours

```dart
abstract final class QRef {
  // Brand seeds
  static const mihrab      = Color(0xFF1F4A3C); // primary, 10.0:1 white-on
  static const sabr        = Color(0xFF8A6F4E);
  static const sabrInk     = Color(0xFF6B563C); // light text variant, 7.0:1
  static const sidr        = Color(0xFFB4552F); // accent, 4.9:1
  static const layl        = Color(0xFF2A5C82); // tertiary / info, 7.1:1

  // Semantic, light
  static const successL    = Color(0xFF2D6A4F); // 6.5:1
  static const warningL    = Color(0xFF8A5A00); // 5.9:1
  static const errorL      = Color(0xFF8C1D18); // 9.2:1

  // Light surfaces
  static const bgL         = Color(0xFFFBF8F3);
  static const surfaceL    = Color(0xFFFFFFFF);
  static const surfaceVarL = Color(0xFFF1EBE1);
  static const dividerL    = Color(0xFFE6E0D6); // decorative only
  static const borderL     = Color(0xFF8F877A); // 3.4:1 sole-affordance
  static const inverseSurfL= Color(0xFF2E312F);

  // Light text and icons
  static const textL       = Color(0xFF16181C); // 16.8:1
  static const textMutedL  = Color(0xFF5A5D63); // 6.2:1
  static const textFaintL  = Color(0xFF7A7D83); // 3.9:1, large text only
  static const textDisabL  = Color(0xFF8B8E94);
  static const iconL       = Color(0xFF3A3D42); // 10.3:1

  // Light containers
  static const primaryContL     = Color(0xFFA8D5C4);
  static const onPrimaryContL   = Color(0xFF002019);
  static const secondaryContL   = Color(0xFFEADDCB);
  static const onSecondaryContL = Color(0xFF241A0C);
  static const errorContL       = Color(0xFFF9DEDC);

  // Dark
  static const bgD         = Color(0xFF14161A);
  static const surfaceD    = Color(0xFF1A1D22);
  static const cardD       = Color(0xFF212429);
  static const dividerD    = Color(0xFF262A30);
  static const borderD     = Color(0xFF3A3F47);
  static const textD       = Color(0xFFE4E1DC); // 13.9:1
  static const textMutedD  = Color(0xFFA8A5A0); // 7.4:1
  static const textFaintD  = Color(0xFF7E7B77); // 4.3:1
  static const textDisabD  = Color(0xFF66635F);
  static const iconD       = Color(0xFFCFCCC7); // 11.3:1

  // AMOLED - ink is NEVER #FFFFFF: halation bleeds Arabic diacritics
  // into the glyph body.
  static const bgA         = Color(0xFF000000);
  static const surfaceA    = Color(0xFF0A0A0B);
  static const cardA       = Color(0xFF0E0F11);
  static const dividerA    = Color(0xFF161616);
  static const borderA     = Color(0xFF2A2A2C);
  static const textA       = Color(0xFFD9D6D1); // 14.5:1
  static const textMutedA  = Color(0xFFA3A09B); // 7.8:1
  static const textFaintA  = Color(0xFF78756F); // 4.2:1
  static const textDisabA  = Color(0xFF605D59);
  static const iconA       = Color(0xFFC6C3BE); // 12.4:1

  // Shared dark / AMOLED brand
  static const primaryDk        = Color(0xFF7FB8A2);
  static const onPrimaryDk      = Color(0xFF00382A);
  static const primaryContDk    = Color(0xFF2B5C4C);
  static const primaryContAm    = Color(0xFF1A3A30);
  static const onPrimaryContDk  = Color(0xFFC4EBD9);
  static const secondaryDk      = Color(0xFFC9AE8B);
  static const onSecondaryDk    = Color(0xFF3A2C18);
  static const accentDk         = Color(0xFFE0906B);
  static const onAccentDk       = Color(0xFF44200E);
  static const successDk        = Color(0xFF7EC8A0);
  static const warningDk        = Color(0xFFE0B65C);
  static const errorDk          = Color(0xFFF2B8B5);
  static const onErrorDk        = Color(0xFF601410);
  static const infoDk           = Color(0xFF9BC4E8);
  static const onTertiaryDk     = Color(0xFF0B2E45);

  // Highlights - non-semantic names
  static const saffronL = Color(0xFFF5E6C3); static const saffronD = Color(0xFF4A4020);
  static const sageL    = Color(0xFFD9E8DC); static const sageD    = Color(0xFF1E3A2C);
  static const skyL     = Color(0xFFD6E4F0); static const skyD     = Color(0xFF1C3446);
  static const roseL    = Color(0xFFF2DCDC); static const roseD    = Color(0xFF442426);
  static const lilacL   = Color(0xFFE4DCEF); static const lilacD   = Color(0xFF332A45);
}
```

---

## 4. Colour schemes

```dart
abstract final class QSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: QRef.mihrab, onPrimary: Color(0xFFFFFFFF),
    primaryContainer: QRef.primaryContL, onPrimaryContainer: QRef.onPrimaryContL,
    secondary: QRef.sabrInk, onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: QRef.secondaryContL, onSecondaryContainer: QRef.onSecondaryContL,
    tertiary: QRef.layl, onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCFE4F5), onTertiaryContainer: Color(0xFF06131E),
    error: QRef.errorL, onError: Color(0xFFFFFFFF),
    errorContainer: QRef.errorContL, onErrorContainer: Color(0xFF410E0B),
    surface: QRef.bgL, onSurface: QRef.textL, onSurfaceVariant: QRef.textMutedL,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFBF8F3),
    surfaceContainer: Color(0xFFF6F1E9),
    surfaceContainerHigh: Color(0xFFF1EBE1),
    surfaceContainerHighest: Color(0xFFEBE4D8),
    outline: QRef.borderL, outlineVariant: QRef.dividerL,
    inverseSurface: QRef.inverseSurfL, onInverseSurface: Color(0xFFF1EFEC),
    inversePrimary: QRef.primaryDk,
    shadow: Color(0xFF000000), scrim: Color(0xFF000000),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: QRef.primaryDk, onPrimary: QRef.onPrimaryDk,
    primaryContainer: QRef.primaryContDk, onPrimaryContainer: QRef.onPrimaryContDk,
    secondary: QRef.secondaryDk, onSecondary: QRef.onSecondaryDk,
    secondaryContainer: Color(0xFF4A3A22), onSecondaryContainer: Color(0xFFEFDDC4),
    tertiary: QRef.infoDk, onTertiary: QRef.onTertiaryDk,
    tertiaryContainer: Color(0xFF1E4462), onTertiaryContainer: Color(0xFFD3E6F7),
    error: QRef.errorDk, onError: QRef.onErrorDk,
    errorContainer: Color(0xFF8C1D18), onErrorContainer: Color(0xFFF9DEDC),
    surface: QRef.bgD, onSurface: QRef.textD, onSurfaceVariant: QRef.textMutedD,
    surfaceContainerLowest: Color(0xFF0E1013),
    surfaceContainerLow: Color(0xFF16191D),
    surfaceContainer: QRef.surfaceD,
    surfaceContainerHigh: QRef.cardD,
    surfaceContainerHighest: Color(0xFF282C32),
    outline: QRef.borderD, outlineVariant: QRef.dividerD,
    inverseSurface: Color(0xFFE4E1DC), onInverseSurface: Color(0xFF16181C),
    inversePrimary: QRef.mihrab,
    shadow: Color(0xFF000000), scrim: Color(0xFF000000),
  );

  /// AMOLED shares the dark brand set but replaces the entire surface ramp
  /// and darkens primaryContainer so it does not glow against pure black.
  static const amoled = ColorScheme(
    brightness: Brightness.dark,
    primary: QRef.primaryDk, onPrimary: QRef.onPrimaryDk,
    primaryContainer: QRef.primaryContAm, onPrimaryContainer: QRef.onPrimaryContDk,
    secondary: QRef.secondaryDk, onSecondary: QRef.onSecondaryDk,
    secondaryContainer: Color(0xFF33270F), onSecondaryContainer: Color(0xFFEFDDC4),
    tertiary: QRef.infoDk, onTertiary: QRef.onTertiaryDk,
    tertiaryContainer: Color(0xFF13293A), onTertiaryContainer: Color(0xFFD3E6F7),
    error: QRef.errorDk, onError: QRef.onErrorDk,
    errorContainer: Color(0xFF5C1512), onErrorContainer: Color(0xFFF9DEDC),
    surface: QRef.bgA, onSurface: QRef.textA, onSurfaceVariant: QRef.textMutedA,
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: QRef.surfaceA,
    surfaceContainer: QRef.cardA,
    surfaceContainerHigh: Color(0xFF141416),
    surfaceContainerHighest: Color(0xFF1A1A1C),
    outline: QRef.borderA, outlineVariant: QRef.dividerA,
    inverseSurface: Color(0xFFD9D6D1), onInverseSurface: Color(0xFF000000),
    inversePrimary: QRef.mihrab,
    shadow: Color(0xFF000000), scrim: Color(0xFF000000),
  );

  static ColorScheme forMode(QThemeMode mode) => switch (mode) {
        QThemeMode.light => light,
        QThemeMode.dark => dark,
        QThemeMode.amoled => amoled,
      };
}
```

---

## 5. Typography

```dart
enum QScript { latin, arabic, quranic }

const double kArabicScale = 1.10;

@immutable
class QFontFace {
  const QFontFace({
    required this.family,
    this.opticalScale = 1.0,
    this.minHeight = 1.0,
    this.availableWeights = const [400, 500, 600, 700],
  });

  final String family;
  final double opticalScale;
  final double minHeight;
  final List<int> availableWeights;

  /// Snaps to the nearest shipped weight. Synthetic bold is never acceptable
  /// on Arabic: the rasteriser thickens diacritics into blobs.
  FontWeight resolveWeight(int requested) {
    final w = availableWeights.reduce(
        (a, b) => (a - requested).abs() < (b - requested).abs() ? a : b);
    return FontWeight.values[(w ~/ 100) - 1];
  }
}

abstract final class QFonts {
  static const interUi = QFontFace(family: 'Inter');
  static const plexArabicUi = QFontFace(
      family: 'IBMPlexSansArabic', opticalScale: kArabicScale, minHeight: 1.70);
  static const literataReading = QFontFace(family: 'Literata', minHeight: 1.55);
  static const notoNaskhReading = QFontFace(
      family: 'NotoNaskhArabic', opticalScale: 1.15, minHeight: 1.80,
      availableWeights: [400, 700]);
  static const uthmanicHafs = QFontFace(
      family: 'KFGQPCUthmanicHafs', opticalScale: kArabicScale,
      minHeight: 2.00, availableWeights: [400]);
}

/// The ONLY TextStyle factory in the codebase.
TextStyle qStyle({
  required QFontFace face,
  required double size,
  int weight = 400,
  double? height,
  double letterSpacing = 0,
  FontStyle fontStyle = FontStyle.normal,
  List<FontFeature> features = const [],
  Color? color,
}) {
  final isArabicFace = face == QFonts.plexArabicUi ||
      face == QFonts.notoNaskhReading ||
      face == QFonts.uthmanicHafs;

  return TextStyle(
    fontFamily: face.family,
    fontSize: size * face.opticalScale,
    fontWeight: face.resolveWeight(weight),
    height: math.max(height ?? 1.4, face.minHeight),
    letterSpacing: isArabicFace ? 0 : letterSpacing, // spacing breaks joining
    fontStyle: isArabicFace ? FontStyle.normal : fontStyle,
    fontFeatures: features,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
```

```dart
TextTheme buildTextTheme({required bool isArabicLocale}) {
  final ui = isArabicLocale ? QFonts.plexArabicUi : QFonts.interUi;
  final ar = isArabicLocale;

  return TextTheme(
    displayLarge:  qStyle(face: ui, size: 57, height: ar ? 1.45 : 1.12),
    displayMedium: qStyle(face: ui, size: 45, height: ar ? 1.45 : 1.16),
    displaySmall:  qStyle(face: ui, size: 36, height: ar ? 1.48 : 1.22),
    headlineLarge:  qStyle(face: ui, size: 32, weight: 500, height: ar ? 1.52 : 1.25),
    headlineMedium: qStyle(face: ui, size: 28, weight: 500, height: ar ? 1.55 : 1.28),
    headlineSmall:  qStyle(face: ui, size: 24, weight: 500, height: ar ? 1.55 : 1.33),
    titleLarge:  qStyle(face: ui, size: 22, weight: 500, height: ar ? 1.55 : 1.27),
    titleMedium: qStyle(face: ui, size: 16, weight: 600, height: ar ? 1.70 : 1.50, letterSpacing: 0.15),
    titleSmall:  qStyle(face: ui, size: 14, weight: 600, height: ar ? 1.70 : 1.43, letterSpacing: 0.10),
    bodyLarge:  qStyle(face: ui, size: 16, height: ar ? 1.70 : 1.50, letterSpacing: 0.50),
    bodyMedium: qStyle(face: ui, size: 14, height: ar ? 1.70 : 1.43, letterSpacing: 0.25),
    bodySmall:  qStyle(face: ui, size: 12, height: ar ? 1.70 : 1.33, letterSpacing: 0.40),
    labelLarge:  qStyle(face: ui, size: 14, weight: 500, height: ar ? 1.70 : 1.43, letterSpacing: 0.10),
    labelMedium: qStyle(face: ui, size: 12, weight: 500, height: ar ? 1.70 : 1.33, letterSpacing: 0.50),
    labelSmall:  qStyle(face: ui, size: 11, weight: 500, height: ar ? 1.70 : 1.45, letterSpacing: 0.50),
  );
}
```

---

## 6. Theme extensions

### 6.1 QSemanticColors

```dart
@immutable
class QSemanticColors extends ThemeExtension<QSemanticColors> {
  const QSemanticColors({
    required this.accent, required this.onAccent,
    required this.success, required this.onSuccess,
    required this.warning, required this.onWarning,
    required this.info, required this.onInfo,
    required this.borderStrong,
    required this.textFaint,
    required this.iconDefault, required this.iconMuted,
    required this.highlights,
  });

  final Color accent, onAccent, success, onSuccess;
  final Color warning, onWarning, info, onInfo;

  /// 3.5:1 minimum. Sole-affordance borders and focus rings.
  /// NOT the same as outlineVariant, which is decorative and exempt.
  final Color borderStrong;

  final Color textFaint;              // large text only
  final Color iconDefault, iconMuted;
  final QHighlightPalette highlights;

  static const light = QSemanticColors(
    accent: QRef.sidr, onAccent: Color(0xFFFFFFFF),
    success: QRef.successL, onSuccess: Color(0xFFFFFFFF),
    warning: QRef.warningL, onWarning: Color(0xFFFFFFFF),
    info: QRef.layl, onInfo: Color(0xFFFFFFFF),
    borderStrong: QRef.borderL, textFaint: QRef.textFaintL,
    iconDefault: QRef.iconL, iconMuted: QRef.textMutedL,
    highlights: QHighlightPalette.light,
  );

  static const dark = QSemanticColors(
    accent: QRef.accentDk, onAccent: QRef.onAccentDk,
    success: QRef.successDk, onSuccess: Color(0xFF00382A),
    warning: QRef.warningDk, onWarning: Color(0xFF3D2A00),
    info: QRef.infoDk, onInfo: QRef.onTertiaryDk,
    borderStrong: QRef.borderD, textFaint: QRef.textFaintD,
    iconDefault: QRef.iconD, iconMuted: QRef.textMutedD,
    highlights: QHighlightPalette.dark,
  );

  static const amoled = QSemanticColors(
    accent: QRef.accentDk, onAccent: QRef.onAccentDk,
    success: QRef.successDk, onSuccess: Color(0xFF00382A),
    warning: QRef.warningDk, onWarning: Color(0xFF3D2A00),
    info: QRef.infoDk, onInfo: QRef.onTertiaryDk,
    borderStrong: QRef.borderA, textFaint: QRef.textFaintA,
    iconDefault: QRef.iconA, iconMuted: QRef.textMutedA,
    highlights: QHighlightPalette.dark,
  );

  static QSemanticColors forMode(QThemeMode m) => switch (m) {
        QThemeMode.light => light,
        QThemeMode.dark => dark,
        QThemeMode.amoled => amoled,
      };

  @override
  QSemanticColors lerp(QSemanticColors? other, double t) {
    if (other == null) return this;
    return QSemanticColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      iconDefault: Color.lerp(iconDefault, other.iconDefault, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      highlights: highlights.lerp(other.highlights, t),
    );
  }

  @override
  QSemanticColors copyWith({Color? accent, Color? success}) => QSemanticColors(
        accent: accent ?? this.accent, onAccent: onAccent,
        success: success ?? this.success, onSuccess: onSuccess,
        warning: warning, onWarning: onWarning,
        info: info, onInfo: onInfo,
        borderStrong: borderStrong, textFaint: textFaint,
        iconDefault: iconDefault, iconMuted: iconMuted,
        highlights: highlights,
      );
}
```

### 6.2 QReadingTheme

```dart
@immutable
class QReadingTheme extends ThemeExtension<QReadingTheme> {
  const QReadingTheme({
    required this.canvas, required this.ink, required this.inkMuted,
    required this.mark, required this.rule,
    required this.mushafStyle, required this.translationStyle,
    required this.transliterationStyle, required this.tafsirStyle,
    required this.verseNumberStyle, required this.footnoteStyle,
  });

  final Color canvas, ink, inkMuted, mark, rule;
  final TextStyle mushafStyle, translationStyle, transliterationStyle;
  final TextStyle tafsirStyle, verseNumberStyle, footnoteStyle;

  /// Em-based so margins scale with the Arabic size slider. Fixed dp margins
  /// look correct at 26sp and absurd at 48sp.
  EdgeInsetsDirectional pageMargins(double mushafSize) =>
      EdgeInsetsDirectional.symmetric(
        horizontal: (mushafSize * 1.6).clamp(20.0, 96.0),
        vertical: mushafSize * 2.0,
      );

  static QReadingTheme resolve({
    required QThemeMode mode,
    required double mushafSize,
    required double translationSize,
  }) {
    final (canvas, ink, inkMuted, mark, rule) = switch (mode) {
      QThemeMode.light  => (QRef.bgL, QRef.textL, QRef.textMutedL, QRef.mihrab, QRef.dividerL),
      QThemeMode.dark   => (QRef.bgD, QRef.textD, const Color(0xFF9A9791), QRef.primaryDk, QRef.dividerD),
      QThemeMode.amoled => (QRef.bgA, QRef.textA, const Color(0xFF8E8B86), QRef.primaryDk, QRef.dividerA),
    };

    return QReadingTheme(
      canvas: canvas, ink: ink, inkMuted: inkMuted, mark: mark, rule: rule,
      mushafStyle: qStyle(face: QFonts.uthmanicHafs,
          size: mushafSize.clamp(18.0, 48.0), height: 2.00, color: ink),
      translationStyle: qStyle(face: QFonts.literataReading,
          size: translationSize.clamp(14.0, 32.0), height: 1.70, color: ink),
      transliterationStyle: qStyle(face: QFonts.literataReading,
          size: (translationSize - 2).clamp(13.0, 28.0), height: 1.60,
          fontStyle: FontStyle.italic, color: inkMuted),
      tafsirStyle: qStyle(face: QFonts.literataReading,
          size: translationSize.clamp(14.0, 30.0), height: 1.75, color: ink),
      verseNumberStyle: qStyle(face: QFonts.uthmanicHafs,
          size: mushafSize * 0.58, height: 1.0, color: mark),
      footnoteStyle: qStyle(face: QFonts.literataReading,
          size: 13, height: 1.55, color: inkMuted),
    );
  }

  @override
  QReadingTheme lerp(QReadingTheme? other, double t) {
    if (other == null) return this;
    return QReadingTheme(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      mark: Color.lerp(mark, other.mark, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      mushafStyle: TextStyle.lerp(mushafStyle, other.mushafStyle, t)!,
      translationStyle: TextStyle.lerp(translationStyle, other.translationStyle, t)!,
      transliterationStyle: TextStyle.lerp(transliterationStyle, other.transliterationStyle, t)!,
      tafsirStyle: TextStyle.lerp(tafsirStyle, other.tafsirStyle, t)!,
      verseNumberStyle: TextStyle.lerp(verseNumberStyle, other.verseNumberStyle, t)!,
      footnoteStyle: TextStyle.lerp(footnoteStyle, other.footnoteStyle, t)!,
    );
  }

  @override
  QReadingTheme copyWith({Color? canvas, Color? ink}) => this;
}
```

### 6.3 QShapeMotion

```dart
@immutable
class QShapeMotion extends ThemeExtension<QShapeMotion> {
  const QShapeMotion({required this.reduceMotion, required this.mode});

  final bool reduceMotion;
  final QThemeMode mode;

  static const none = BorderRadius.zero;
  static const xs   = BorderRadius.all(Radius.circular(4));
  static const sm   = BorderRadius.all(Radius.circular(8));
  static const md   = BorderRadius.all(Radius.circular(12));
  static const lg   = BorderRadius.all(Radius.circular(16));
  static const xl   = BorderRadius.all(Radius.circular(28));
  static const full = BorderRadius.all(Radius.circular(999));

  /// Reduced motion caps duration rather than removing it. Opacity change is
  /// not a vestibular trigger; large displacement is.
  Duration duration(Duration normal) => reduceMotion
      ? Duration(milliseconds: math.min(normal.inMilliseconds, 150))
      : normal;

  @override
  QShapeMotion copyWith({bool? reduceMotion, QThemeMode? mode}) => QShapeMotion(
      reduceMotion: reduceMotion ?? this.reduceMotion, mode: mode ?? this.mode);

  /// Booleans and enums do not interpolate meaningfully.
  @override
  QShapeMotion lerp(QShapeMotion? other, double t) => t < 0.5 ? this : (other ?? this);
}
```

### 6.4 Typed access

```dart
extension QThemeX on BuildContext {
  ColorScheme     get colors   => Theme.of(this).colorScheme;
  TextTheme       get text     => Theme.of(this).textTheme;
  QSemanticColors get semantic => Theme.of(this).extension<QSemanticColors>()!;
  QReadingTheme   get reading  => Theme.of(this).extension<QReadingTheme>()!;
  QShapeMotion    get shape    => Theme.of(this).extension<QShapeMotion>()!;
  QTypography     get typo     => Theme.of(this).extension<QTypography>()!;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
```

The `!` is deliberate. A missing extension is a build-configuration bug that should crash loudly in development, not degrade silently into a fallback that ships.

---

## 7. Elevation strategy

```dart
abstract final class QElevation {
  static const levels = [0.0, 1.0, 3.0, 6.0, 8.0, 12.0];

  static const _amoledHairlines = [
    null,
    Color(0xFF161616), Color(0xFF1A1A1A), Color(0xFF1E1E1E),
    Color(0xFF242424), Color(0xFF2A2A2C),
  ];

  static ShapeBorder? borderFor(QThemeMode mode, int level) {
    if (!mode.usesHairlineElevation || level == 0) return null;
    return RoundedRectangleBorder(
      borderRadius: QShapeMotion.md,
      side: BorderSide(color: _amoledHairlines[level]!, width: 1),
    );
  }

  static double shadowElevation(QThemeMode mode, int level) =>
      mode.usesShadows ? levels[level] : 0;

  static double surfaceTint(QThemeMode mode, int level) =>
      mode.usesHairlineElevation ? 0 : levels[level];
}
```

---

## 8. Dynamic colour

```dart
abstract final class QDynamicColor {
  /// Policy:
  ///  - Chrome (nav, app bar, chips) MAY take platform dynamic colour.
  ///  - Reading surfaces NEVER do. A wallpaper-derived palette cannot be
  ///    guaranteed to hold the 12:1 Quranic contrast floor.
  ///  - Semantic colours NEVER do. Success/warning/error must be stable.
  static ColorScheme? resolve({
    required ColorScheme? platform,
    required QThemeMode mode,
    required bool userEnabled,
  }) {
    if (!userEnabled || platform == null) return null;

    final base = QSchemes.forMode(mode);
    final harmonised = platform.harmonized();

    final candidate = base.copyWith(
      primary: harmonised.primary,
      onPrimary: harmonised.onPrimary,
      primaryContainer: harmonised.primaryContainer,
      onPrimaryContainer: harmonised.onPrimaryContainer,
      secondary: harmonised.secondary,
      onSecondary: harmonised.onSecondary,
    );

    // Verify before adopting. Material harmonisation preserves hue
    // relationships, not contrast ratios.
    final ok = _contrast(candidate.onPrimary, candidate.primary) >= 4.5 &&
        _contrast(candidate.onPrimaryContainer, candidate.primaryContainer) >= 4.5;

    return ok ? candidate : null;
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }
}
```

Verifying contrast before adopting a dynamic scheme is the part most implementations skip. Without it a user with a pale wallpaper ends up with 2.8:1 button text.

---

## 9. Component themes

```dart
SwitchThemeData qSwitchTheme(ColorScheme cs) => SwitchThemeData(
      // The check glyph is mandatory. Track colour alone does not communicate
      // state to users with a colour vision deficiency.
      thumbIcon: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Icon(Icons.check, size: 16, color: cs.onPrimary)
              : null),
      trackOutlineColor: WidgetStatePropertyAll(cs.outline),
    );

ChipThemeData qChipTheme(ColorScheme cs, TextTheme t) => ChipThemeData(
      labelStyle: t.labelLarge,
      shape: const RoundedRectangleBorder(borderRadius: QShapeMotion.sm),
      backgroundColor: cs.surfaceContainerHigh,
      selectedColor: cs.secondaryContainer,
      showCheckmark: true,               // never colour-only selection
      checkmarkColor: cs.onSecondaryContainer,
      side: BorderSide(color: cs.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );

FilledButtonThemeData qFilledButtonTheme(ColorScheme cs, TextTheme t) =>
    FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)), // 48dp floor
        padding: const WidgetStatePropertyAll(
            EdgeInsetsDirectional.symmetric(horizontal: 20)),
        shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: QShapeMotion.md)),
        textStyle: WidgetStatePropertyAll(t.labelLarge),
        animationDuration: QMotion.short,  // no press-scale
        elevation: const WidgetStatePropertyAll(0),
      ),
    );

NavigationBarThemeData qNavBarTheme(ColorScheme cs, TextTheme t, QThemeMode mode) =>
    NavigationBarThemeData(
      height: 80,
      backgroundColor: cs.surfaceContainer,
      elevation: mode.usesHairlineElevation ? 0 : 3,
      surfaceTintColor:
          mode.usesHairlineElevation ? Colors.transparent : cs.surfaceTint,
      indicatorColor: cs.secondaryContainer,
      indicatorShape: const RoundedRectangleBorder(borderRadius: QShapeMotion.lg),
      // Labels ALWAYS visible. Icon-only navigation fails our less
      // technically confident personas.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(t.labelMedium),
    );
```

Coverage must be exhaustive: buttons (5), inputs, card, dialog, sheet, snackbar, banner, nav bar, rail, drawer, tabs, app bar (4 variants), switch, checkbox, radio, chip, slider, segmented, progress (2), tooltip, divider, badge, list tile, popup menu, expansion tile. Anything unthemed will be styled at a call site within a sprint.

---

## 10. buildTheme

```dart
ThemeData buildTheme(QThemeInput input) {
  final mode = input.mode;
  final cs = input.dynamicScheme ?? QSchemes.forMode(mode);
  final tt = buildTextTheme(isArabicLocale: input.isArabicLocale);

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: tt,
    brightness: cs.brightness,
    scaffoldBackgroundColor: cs.surface,
    canvasColor: cs.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,

    // Fade-through everywhere: lateral slides encode a direction that is not
    // stable across LTR and RTL.
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
    }),

    filledButtonTheme: qFilledButtonTheme(cs, tt),
    outlinedButtonTheme: qOutlinedButtonTheme(cs, tt),
    textButtonTheme: qTextButtonTheme(cs, tt),
    iconButtonTheme: qIconButtonTheme(cs),
    cardTheme: qCardTheme(cs, mode),
    dialogTheme: qDialogTheme(cs, tt),
    bottomSheetTheme: qSheetTheme(cs, mode),
    snackBarTheme: qSnackBarTheme(cs, tt),
    navigationBarTheme: qNavBarTheme(cs, tt, mode),
    navigationRailTheme: qRailTheme(cs, tt, mode),
    appBarTheme: qAppBarTheme(cs, tt, mode),
    tabBarTheme: qTabBarTheme(cs, tt),
    switchTheme: qSwitchTheme(cs),
    checkboxTheme: qCheckboxTheme(cs),
    radioTheme: qRadioTheme(cs),
    chipTheme: qChipTheme(cs, tt),
    sliderTheme: qSliderTheme(cs),
    progressIndicatorTheme: qProgressTheme(cs),
    inputDecorationTheme: qInputTheme(cs, tt),
    dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),
    tooltipTheme: qTooltipTheme(cs, tt),
    listTileTheme: qListTileTheme(cs, tt),

    extensions: <ThemeExtension<dynamic>>[
      QSemanticColors.forMode(mode),
      QReadingTheme.resolve(
        mode: mode,
        mushafSize: input.mushafSize,
        translationSize: input.translationSize,
      ),
      QShapeMotion(reduceMotion: input.reduceMotion, mode: mode),
      QTypography.resolve(
        isArabicLocale: input.isArabicLocale,
        mushafSize: input.mushafSize,
        translationSize: input.translationSize,
      ),
    ],
  );
}
```

---

## 11. Controller and wiring

```dart
@riverpod
class ThemeController extends _$ThemeController {
  @override
  QThemePreferences build() =>
      ref.watch(preferencesRepositoryProvider).themePreferences();

  Future<void> setMode(QThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await ref.read(preferencesRepositoryProvider).saveThemeMode(mode);
  }

  Future<void> setMushafSize(double size) async {
    state = state.copyWith(mushafSize: size.clamp(18.0, 48.0));
    await ref.read(preferencesRepositoryProvider).saveMushafSize(state.mushafSize);
  }
}

/// Memoised: ThemeData is expensive and the size sliders emit continuously
/// while dragged. Equality on QThemeInput is what makes this work.
@riverpod
ThemeData appTheme(AppThemeRef ref, QThemeInput input) => buildTheme(input);
```

```dart
class QuranOneApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final mode = prefs.followSystem
        ? (platformBrightness == Brightness.dark ? prefs.darkVariant : QThemeMode.light)
        : prefs.mode;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final input = QThemeInput(
          mode: mode,
          locale: locale,
          dynamicScheme: QDynamicColor.resolve(
            platform: mode.isDark ? darkDynamic : lightDynamic,
            mode: mode,
            userEnabled: prefs.dynamicColor,
          ),
          mushafSize: prefs.mushafSize,
          translationSize: prefs.translationSize,
          reduceMotion:
              prefs.reduceMotion || MediaQuery.disableAnimationsOf(context),
        );

        return MaterialApp.router(
          theme: ref.watch(appThemeProvider(input)),
          themeAnimationDuration: QMotion.medium,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: ref.watch(routerProvider),
          // Text scale is NEVER clamped. Layouts reflow instead.
          builder: (context, child) =>
              QMotionScope(reduced: input.reduceMotion, child: child!),
        );
      },
    );
  }
}
```

`prefs.darkVariant` is why AMOLED works with follow-system: the OS reports only light or dark, so the user's choice of which dark theme is stored separately.

---

## 12. RTL support

| Concern | Mechanism |
| --- | --- |
| Direction | `Directionality` from the `MaterialApp` locale, never hard-coded |
| Padding in themes | `EdgeInsetsDirectional` in every component theme |
| Icons | `matchTextDirection: true` on directional icons only |
| Page transitions | Non-directional fade-through by default |
| Mushaf page turn | **Always RTL, in every locale** - the documented exception |
| Fonts | `buildTextTheme(isArabicLocale:)` swaps the entire UI face |
| Bidi isolation | `\u2068` / `\u2069` around opposite-direction interpolations |

Banned APIs, rejected by lint at merge: `EdgeInsets.only(left:)`, `Alignment.centerLeft`, `Positioned(left:)`, `TextAlign.left`, `BorderRadius.only(topLeft:)`.

---

## 13. Coding standards

### 13.1 Rules

| # | Rule | Enforcement |
| --- | --- | --- |
| 1 | `TextStyle(` appears only inside `q_style.dart` | Lint |
| 2 | `Color(0x...)` appears only inside `q_ref_colors.dart` | Lint |
| 3 | No `colorScheme.x.withOpacity(y)` - add a token instead | Lint |
| 4 | No `Duration(` outside `QMotion` | Lint |
| 5 | No `Curves.` outside `QEasing`; elastic/bounce/back banned | Lint |
| 6 | No `EdgeInsets` literal off the 4dp scale | Lint |
| 7 | Feature code imports `core/theme/theme.dart` only | Import lint |
| 8 | Every `ThemeExtension` implements `copyWith` and `lerp` | Analyzer |
| 9 | No `MediaQuery.copyWith(textScaler:)` anywhere | Lint |
| 10 | No Material widget imported outside `design_system/` | Import lint |
| 11 | `ThemeData` built only by `buildTheme` | Lint |
| 12 | No `ColorScheme.fromSeed` in runtime code | Lint |

### 13.2 Naming

| Kind | Convention | Example |
| --- | --- | --- |
| Reference constants | `QRef.<name>` | `QRef.mihrab` |
| Schemes | `QSchemes.<mode>` | `QSchemes.amoled` |
| Extensions | `Q<Domain>Theme` / `Q<Domain>Colors` | `QReadingTheme` |
| Component factories | `q<Widget>Theme(cs, tt)` | `qChipTheme` |
| Components | `Q`-prefixed | `QAyahCard` |
| Goldens | `<component>_<theme>_<scale>_<dir>.png` | `ayah_card_amoled_2x_rtl.png` |

### 13.3 Tests

```dart
void main() {
  for (final mode in QThemeMode.values) {
    test('$mode meets every contrast floor', () {
      final theme = buildTheme(QThemeInput(mode: mode, locale: const Locale('en')));
      final reading = theme.extension<QReadingTheme>()!;

      expect(contrast(reading.ink, reading.canvas), greaterThanOrEqualTo(12.0),
          reason: 'Quranic text floor');
      expect(contrast(theme.colorScheme.onSurface, theme.colorScheme.surface),
          greaterThanOrEqualTo(5.5), reason: 'body text floor');
      expect(
          contrast(theme.extension<QSemanticColors>()!.borderStrong,
              theme.colorScheme.surface),
          greaterThanOrEqualTo(3.5), reason: 'sole-affordance border floor');
    });

    test('$mode declares all four extensions', () {
      final t = buildTheme(QThemeInput(mode: mode, locale: const Locale('en')));
      expect(t.extension<QSemanticColors>(), isNotNull);
      expect(t.extension<QReadingTheme>(), isNotNull);
      expect(t.extension<QShapeMotion>(), isNotNull);
      expect(t.extension<QTypography>(), isNotNull);
    });
  }

  test('AMOLED surface is pure black and ink is never pure white', () {
    final t = buildTheme(
        const QThemeInput(mode: QThemeMode.amoled, locale: Locale('en')));
    expect(t.colorScheme.surface, const Color(0xFF000000));
    expect(t.colorScheme.onSurface, isNot(const Color(0xFFFFFFFF)));
  });

  test('buildTheme is pure - identical input yields identical output', () {
    const input = QThemeInput(mode: QThemeMode.dark, locale: Locale('ar'));
    expect(buildTheme(input).colorScheme, buildTheme(input).colorScheme);
  });
}
```

24 goldens per component: 3 themes x 2 directions x 4 text scales.

---

## 14. Clean Architecture placement

```
domain/
  entities/     QThemePreferences        # pure Dart, no Flutter import
  repositories/ PreferencesRepository    # abstract

data/
  repositories/ PreferencesRepositoryImpl
  sources/      SharedPrefsThemeSource

core/theme/     buildTheme + tokens      # Flutter, no domain dependency

presentation/   ThemeController          # bridges domain prefs -> QThemeInput
```

The direction of dependency is what matters: `core/theme` knows nothing about the repository, and `domain` knows nothing about Flutter. `QThemeInput` is the seam, which is why `buildTheme` can be tested with no mocks, no `pumpWidget` and no plugin registration.

---

## 15. Four positions worth arguing about

**1. Hand-authoring three `ColorScheme`s is about 150 lines of constants to maintain; seeding is one line.** Seeding also cannot hit 12:1 on Quranic text, produces a slightly different palette on every Flutter upgrade as the tonal algorithm evolves, and costs a HCT solve per build. Constants are boring and auditable.

**2. Rejecting a dynamic scheme that fails contrast means some users get dynamic colour and some silently do not.** That inconsistency is the price of a floor that actually holds.

**3. Banning `withOpacity` on scheme colours will feel pedantic.** It is the single most common way a design system leaks: one `withOpacity(0.12)` becomes forty, at eleven undocumented values.

**4. Four extensions is more indirection than most Flutter apps carry, and `QReadingTheme` rebuilds on every slider tick.** Memoisation handles it, but it depends on `operator ==` staying correct - exactly the thing that breaks silently when someone adds a field. Worth a test that asserts the field count.
