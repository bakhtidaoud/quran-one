import 'package:flutter/material.dart';

/// Shape and motion tokens.
///
/// Raw Duration and Curves literals outside this file are banned by lint,
/// which is the only way reduced-motion stays honest across fifteen features.
@immutable
class QShapeMotion extends ThemeExtension<QShapeMotion> {
  const QShapeMotion({required this.radiusScale, required this.reduceMotion});

  final double radiusScale;
  final bool reduceMotion;

  static const instant = Duration(milliseconds: 50);
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const long = Duration(milliseconds: 400);
  static const page = Duration(milliseconds: 350);
  static const sheet = Duration(milliseconds: 350);
  static const sheetExit = Duration(milliseconds: 250);

  static const standard = Cubic(0.2, 0, 0, 1);
  static const decelerate = Cubic(0, 0, 0, 1);
  static const accelerate = Cubic(0.3, 0, 1, 1);

  double get none => 0;
  double get xs => 4 * radiusScale;
  double get sm => 8 * radiusScale;
  double get md => 12 * radiusScale;
  double get lg => 16 * radiusScale;
  double get xl => 28 * radiusScale;
  double get full => 999;

  /// Clamps to 150ms under reduced motion rather than dropping to zero:
  /// an instant state change is disorienting, a fast one is not.
  Duration duration(Duration base) => reduceMotion
      ? Duration(milliseconds: base.inMilliseconds.clamp(0, 150))
      : base;

  @override
  QShapeMotion copyWith({double? radiusScale, bool? reduceMotion}) =>
      QShapeMotion(
        radiusScale: radiusScale ?? this.radiusScale,
        reduceMotion: reduceMotion ?? this.reduceMotion,
      );

  /// Booleans do not interpolate. Snapping at the midpoint is correct here.
  @override
  QShapeMotion lerp(ThemeExtension<QShapeMotion>? other, double t) {
    if (other is! QShapeMotion) return this;
    return t < 0.5 ? this : other;
  }
}
