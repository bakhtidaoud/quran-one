import 'package:flutter/foundation.dart';

/// Reading pace, measured from this user, never assumed.
///
/// A global constant such as fifteen words per minute is wrong for
/// everyone: a hafiz reviewing moves several times faster than a
/// beginner sounding out letters, and a translation reader faster than
/// both. A wrong estimate is worse than no estimate, because "8 minutes
/// left" on something that takes forty is a small betrayal in every
/// single session.
@immutable
class ReadingPace {
  const ReadingPace({required this.secondsPerAyah, required this.samples});

  const ReadingPace.unknown()
      : secondsPerAyah = 0,
        samples = 0;

  /// Completed sessions of at least five minutes needed before any
  /// estimate is shown at all.
  static const minSamples = 3;

  final double secondsPerAyah;
  final int samples;

  bool get isConfident => samples >= minSamples && secondsPerAyah > 0;

  /// Exponential moving average. Recent sessions matter more: pace
  /// changes with the surah, the time of day and whether the user is
  /// reading translation alongside.
  ReadingPace withSession({
    required int ayahsRead,
    required Duration duration,
  }) {
    if (ayahsRead <= 0 || duration < const Duration(minutes: 5)) {
      return this;
    }
    final observed = duration.inSeconds / ayahsRead;
    if (samples == 0) {
      return ReadingPace(secondsPerAyah: observed, samples: 1);
    }
    const alpha = 0.3;
    return ReadingPace(
      secondsPerAyah: secondsPerAyah * (1 - alpha) + observed * alpha,
      samples: samples + 1,
    );
  }

  /// Deliberately coarse, rounded to five minutes.
  ///
  /// "About 12 minutes" is honest. "11 min 47 s" claims a precision
  /// that does not exist and invites the user to treat scripture as a
  /// timed task.
  ///
  /// Returns null until confident. The caller must render nothing
  /// rather than a placeholder.
  Duration? estimate(int ayahsRemaining) {
    if (!isConfident || ayahsRemaining <= 0) return null;
    final raw = (secondsPerAyah * ayahsRemaining).round();
    if (raw < 60) return const Duration(minutes: 1);
    final minutes = ((raw / 60) / 5).round() * 5;
    return Duration(minutes: minutes.clamp(1, 600));
  }
}
