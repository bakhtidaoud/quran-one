import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Arabic is set 10% larger than Latin at the same nominal size, because
/// Arabic letterforms carry their meaning below the baseline and in the
/// diacritics.
const double kArabicScale = 1.10;

/// A typeface plus the constraints that keep it legible.
class QFontFace {
  const QFontFace({
    required this.family,
    required this.opticalScale,
    required this.minHeight,
    required this.availableWeights,
  });

  final String family;

  /// Multiplier applied to nominal size so that two faces at "16" look the
  /// same size on screen.
  final double opticalScale;

  /// Line height floor. Arabic diacritics collide below this.
  final double minHeight;

  final List<int> availableWeights;

  /// Snaps to the nearest shipped weight.
  ///
  /// Never let the rasteriser synthesise a bold Arabic face: it thickens the
  /// diacritics into illegibility.
  FontWeight resolveWeight(FontWeight requested) {
    final target = requested.value;
    var best = availableWeights.first;
    for (final w in availableWeights) {
      if ((w - target).abs() < (best - target).abs()) best = w;
    }
    return FontWeight.values.firstWhere(
      (w) => w.value == best,
      orElse: () => FontWeight.w400,
    );
  }
}

abstract final class QFonts {
  static const inter = QFontFace(
    family: 'Inter',
    opticalScale: 1,
    minHeight: 1.4,
    availableWeights: [400, 500, 600, 700],
  );

  static const plexArabic = QFontFace(
    family: 'IBMPlexSansArabic',
    opticalScale: kArabicScale,
    minHeight: 1.7,
    availableWeights: [400, 500, 600, 700],
  );

  static const literata = QFontFace(
    family: 'Literata',
    opticalScale: 1,
    minHeight: 1.5,
    availableWeights: [400, 600],
  );

  /// Mushaf face. Ships in a content pack, not in the bundle.
  static const uthmanic = QFontFace(
    family: 'KFGQPCUthmanicHafs',
    opticalScale: 1.15,
    minHeight: 2,
    availableWeights: [400],
  );
}

/// The only TextStyle factory in the codebase.
///
/// Constructing TextStyle directly outside token files is banned by lint,
/// because it is how letter-spacing creeps onto Arabic text.
TextStyle qStyle({
  required QFontFace face,
  required double size,
  required FontWeight weight,
  required double height,
  Color? color,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final isArabic = face.family == QFonts.plexArabic.family ||
      face.family == QFonts.uthmanic.family;

  return TextStyle(
    fontFamily: face.family,
    fontSize: size * face.opticalScale,
    fontWeight: face.resolveWeight(weight),
    height: math.max(height, face.minHeight),
    // Arabic is a connected script. Any tracking breaks the joins.
    letterSpacing: isArabic ? 0 : letterSpacing,
    fontStyle: FontStyle.normal,
    color: color,
    decoration: decoration,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
