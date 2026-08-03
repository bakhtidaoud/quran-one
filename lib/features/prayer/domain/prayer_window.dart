import 'package:flutter/foundation.dart';
import 'package:quran_one/features/home/presentation/controllers/countdown.dart'
    show Prayer;

/// A prayer window: from the adhan that opens it to the next adhan.
///
/// The progress ring on the hero card shows progress through *this
/// window*, not through the day. "How much of Asr is left before
/// Maghrib closes it" is a question people genuinely ask. "How far
/// through 24 hours am I" is not.
@immutable
class PrayerWindow {
  const PrayerWindow({
    required this.prayer,
    required this.openedAt,
    required this.closesAt,
    required this.now,
  });

  final Prayer prayer;
  final DateTime openedAt;
  final DateTime closesAt;
  final DateTime now;

  Duration get total => closesAt.difference(openedAt);
  Duration get elapsed => now.difference(openedAt);
  Duration get remaining => closesAt.difference(now);

  /// 0.0 at the adhan, 1.0 when the next one is called.
  double get progress {
    final seconds = total.inSeconds;
    if (seconds <= 0) return 1;
    return (elapsed.inSeconds / seconds).clamp(0.0, 1.0);
  }

  /// The last stretch, where the ring turns from informative to urgent.
  ///
  /// Fifteen minutes rather than a percentage: a percentage makes Asr
  /// in winter, a two hour window, warn far later in absolute terms
  /// than Maghrib, which can be under forty minutes. Urgency is
  /// measured in minutes, because minutes are what it costs to pray.
  ///
  /// This threshold is invented and should be tuned against real data,
  /// very possibly per prayer.
  static const closingThreshold = Duration(minutes: 15);

  bool get isClosing =>
      !remaining.isNegative && remaining < closingThreshold;

  /// Isha runs to Fajr. Without accounting for this the ring reads as
  /// a few percent for hours.
  bool get spansMidnight => closesAt.day != openedAt.day;
}
