import 'package:flutter/foundation.dart';

/// Countdown model for the home prayer card.
///
/// Pure Dart on purpose: the granularity rules below are the part most
/// likely to be got wrong, and they are worth testing without a widget
/// tree.
///
/// Ticking once a second all day is both a battery drain and an anxiety
/// machine. Precision therefore tightens as the prayer approaches and
/// nowhere else.
enum CountdownPrecision {
  /// "in 2h 15m", rebuilt once a minute.
  hoursMinutes(Duration(minutes: 1)),

  /// "in 42m", rebuilt once a minute.
  minutes(Duration(minutes: 1)),

  /// "in 4:32", rebuilt once a second.
  minutesSeconds(Duration(seconds: 1)),

  /// The adhan has been called. Nothing counts down.
  now(Duration(minutes: 1));

  const CountdownPrecision(this.tick);

  /// How often a widget showing this precision must rebuild.
  final Duration tick;
}

/// After the adhan the card stays on the prayer that has just entered
/// rather than jumping to the next one.
///
/// This is the detail that separates a card that answers the question
/// from a card that answers a different question. For twenty minutes
/// after the adhan the user is deciding whether they have prayed yet;
/// showing them Maghrib during Asr is useless.
const kPostAdhanWindow = Duration(minutes: 20);

/// The threshold at which the countdown starts showing seconds.
const kSecondsThreshold = Duration(minutes: 5);

@immutable
class Countdown {
  const Countdown({
    required this.prayer,
    required this.at,
    required this.remaining,
    required this.precision,
    this.previousPrayer,
    this.sincePrevious,
  });

  /// Builds the countdown for [now] from an ordered list of today's
  /// prayer instants.
  ///
  /// [times] must be sorted ascending and may span into tomorrow so
  /// that Isha rolls over to Fajr without a special case at the caller.
  factory Countdown.resolve({
    required List<PrayerInstant> times,
    required DateTime now,
  }) {
    assert(times.isNotEmpty, 'resolve() needs at least one prayer instant');

    PrayerInstant? previous;
    for (final instant in times) {
      final delta = instant.at.difference(now);

      if (delta.isNegative) {
        if (-delta <= kPostAdhanWindow) {
          // Inside the window: hold on the prayer that has entered.
          return Countdown(
            prayer: instant.prayer,
            at: instant.at,
            remaining: Duration.zero,
            precision: CountdownPrecision.now,
            previousPrayer: previous?.prayer,
            sincePrevious:
                previous == null ? null : now.difference(previous.at),
          );
        }
        previous = instant;
        continue;
      }

      return Countdown(
        prayer: instant.prayer,
        at: instant.at,
        remaining: delta,
        precision: precisionFor(delta),
        previousPrayer: previous?.prayer,
        sincePrevious: previous == null ? null : now.difference(previous.at),
      );
    }

    // Past every instant supplied. The caller did not extend the list
    // into tomorrow; hold on the last prayer rather than render an
    // empty card.
    final last = times.last;
    return Countdown(
      prayer: last.prayer,
      at: last.at,
      remaining: Duration.zero,
      precision: CountdownPrecision.now,
      previousPrayer: last.prayer,
      sincePrevious: now.difference(last.at),
    );
  }

  static CountdownPrecision precisionFor(Duration remaining) {
    if (remaining <= Duration.zero) return CountdownPrecision.now;
    if (remaining < kSecondsThreshold) return CountdownPrecision.minutesSeconds;
    if (remaining < const Duration(hours: 1)) return CountdownPrecision.minutes;
    return CountdownPrecision.hoursMinutes;
  }

  final Prayer prayer;
  final DateTime at;
  final Duration remaining;
  final CountdownPrecision precision;

  /// The prayer before this one, when there is one today.
  final Prayer? previousPrayer;

  /// How long ago [previousPrayer] was called.
  final Duration? sincePrevious;

  bool get isNow => precision == CountdownPrecision.now;

  /// Whether the muted "Dhuhr passed 2h ago" line should be shown.
  ///
  /// Suppressed beyond six hours: after that it is no longer reassurance
  /// about a prayer you might have missed, it is just a stale fact.
  bool get showsElapsed =>
      previousPrayer != null &&
      sincePrevious != null &&
      sincePrevious! < const Duration(hours: 6);
}

/// A prayer and the instant it is called, in local time.
@immutable
class PrayerInstant {
  const PrayerInstant(this.prayer, this.at);

  final Prayer prayer;
  final DateTime at;
}

/// Mirrors the profile domain enum. Prayer names are never translated,
/// in any of the twelve supported locales, including inside semantic
/// labels.
enum Prayer { fajr, dhuhr, asr, maghrib, isha }
