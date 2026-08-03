import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/extensions/q_reading_theme.dart';
import 'package:quran_one/core/theme/extensions/q_semantic_colors.dart';
import 'package:quran_one/core/theme/extensions/q_shape_motion.dart';

/// Short accessors so that widget code never writes
/// `Theme.of(context).extension<...>()!`.
extension QThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  QSemanticColors get semantic =>
      Theme.of(this).extension<QSemanticColors>()!;

  QReadingTheme get reading => Theme.of(this).extension<QReadingTheme>()!;

  QShapeMotion get shape => Theme.of(this).extension<QShapeMotion>()!;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
