import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/color/q_color_schemes.dart';
import 'package:quran_one/core/theme/extensions/q_reading_theme.dart';
import 'package:quran_one/core/theme/extensions/q_semantic_colors.dart';
import 'package:quran_one/core/theme/extensions/q_shape_motion.dart';
import 'package:quran_one/core/theme/q_theme_mode.dart';
import 'package:quran_one/core/theme/typography/q_text_theme.dart';

/// Everything the theme depends on, in one value type.
///
/// Value equality matters: it is what lets the theme be memoised instead of
/// rebuilt on every frame.
@immutable
class QThemeInput {
  const QThemeInput({
    required this.mode,
    required this.locale,
    this.dynamicScheme,
    this.mushafSize = 26,
    this.translationSize = 17,
    this.reduceMotion = false,
  });

  final QThemeMode mode;
  final Locale locale;
  final ColorScheme? dynamicScheme;
  final double mushafSize;
  final double translationSize;
  final bool reduceMotion;

  static const _rtlLanguages = {'ar', 'fa', 'ur', 'ps', 'sd', 'ku'};

  bool get isArabicLocale => _rtlLanguages.contains(locale.languageCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QThemeInput &&
          other.mode == mode &&
          other.locale == locale &&
          other.dynamicScheme == dynamicScheme &&
          other.mushafSize == mushafSize &&
          other.translationSize == translationSize &&
          other.reduceMotion == reduceMotion;

  @override
  int get hashCode => Object.hash(
        mode,
        locale,
        dynamicScheme,
        mushafSize,
        translationSize,
        reduceMotion,
      );
}

/// Pure function. No BuildContext, no providers, no I/O.
///
/// That purity is what makes 2,416 golden comparisons possible in one run.
ThemeData buildTheme(QThemeInput input) {
  final scheme = input.dynamicScheme ?? QSchemes.forMode(input.mode);
  final text = buildTextTheme(isArabicLocale: input.isArabicLocale);
  final semantic = QSemanticColors.forMode(input.mode);
  final shape = QShapeMotion(
    radiusScale: 1,
    reduceMotion: input.reduceMotion,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    extensions: [
      semantic,
      shape,
      QReadingTheme.resolve(
        mode: input.mode,
        mushafSize: input.mushafSize,
        translationSize: input.translationSize,
      ),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: input.mode.usesShadows ? 3 : 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    dividerTheme: DividerThemeData(
      color: semantic.divider,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: input.mode.usesShadows ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.md),
        // On AMOLED, separation comes from a hairline, not from elevation.
        side: input.mode.usesHairlineElevation
            ? BorderSide(color: semantic.divider)
            : BorderSide.none,
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shape.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: text.labelLarge,
        side: BorderSide(color: semantic.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shape.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        textStyle: text.labelLarge,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.secondaryContainer,
      height: 80,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.sm),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.xl),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(shape.xl)),
      ),
    ),
  );
}
