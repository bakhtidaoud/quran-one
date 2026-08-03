import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/prayer/domain/prayer_window.dart';

/// Progress ring for the prayer hero card.
///
/// Excluded from semantics entirely. It carries no information the
/// countdown text does not already state, and a screen reader user
/// hearing "progress indicator, 62 percent" learns nothing about
/// prayer. A ring must never be the sole carrier of anything.
class QPrayerProgressRing extends StatelessWidget {
  const QPrayerProgressRing({
    required this.window,
    required this.child,
    super.key,
  });

  final PrayerWindow window;

  /// The countdown readout, which is the actual answer.
  final Widget child;

  static const diameter = 200.0;
  static const _stroke = 6.0;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final onContainer = context.colors.onPrimaryContainer;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: diameter,
        child: CustomPaint(
          painter: _RingPainter(
            progress: window.progress,
            track: onContainer.withValues(alpha: 0.14),
            // Warning, not error. A closing window is a nudge, and the
            // error red on a prayer card reads as a scolding.
            fill: window.isClosing ? semantic.warning : onContainer,
            stroke: _stroke,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
    required this.stroke,
  });

  final double progress;
  final Color track;
  final Color fill;
  final double stroke;

  /// Starts at the top and sweeps clockwise in both text directions.
  ///
  /// Deliberately not mirrored for RTL. A clock face does not mirror in
  /// Arabic and neither does the sun; mirroring a time progress ring
  /// makes it read as counting backwards.
  static const _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = (Offset.zero & size).deflate(stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;

    canvas.drawArc(inset, 0, math.pi * 2, false, paint);

    if (progress <= 0) return;

    canvas.drawArc(
      inset,
      _startAngle,
      math.pi * 2 * progress,
      false,
      paint..color = fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.fill != fill ||
      old.track != track ||
      old.stroke != stroke;
}
