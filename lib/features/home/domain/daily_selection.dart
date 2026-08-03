import 'package:quran_one/features/home/domain/feed_item.dart';

/// Deterministic daily selection.
///
/// The set is chosen by a pure function of the date and the installed
/// content pack version. No server call, no model, no request at all.
///
/// This buys four things that a recommender cannot:
///
///   1. It works offline, which is the default state of this app.
///   2. It is identical on every device the user owns, without sync.
///   3. It is reproducible: given a date and a pack version, a scholar
///      reviewing a complaint can regenerate exactly what was shown.
///   4. It reveals nothing. A server that picks your verse learns what
///      you were shown, and inference over religious content is
///      Article 9 special category processing.
class DailySelection {
  const DailySelection({required this.packVersion});

  /// Mixed into the seed so a pack update reshuffles the rotation
  /// rather than replaying the same order over a different pool.
  final String packVersion;

  /// Days since the Unix epoch in the user's local zone.
  ///
  /// Local, not UTC: the day must turn over at the user's midnight.
  /// A user in Casablanca and a user in Jakarta legitimately see
  /// different items for several hours, and that is correct.
  static int dayNumber(DateTime localNow) =>
      DateTime(localNow.year, localNow.month, localNow.day)
          .difference(DateTime(1970))
          .inDays;

  /// Splitmix64 style mixing, truncated to 32 bits so the result is
  /// identical on web, where integers are doubles.
  static int _mix(int seed) {
    var x = seed & 0x7FFFFFFF;
    x = (x ^ (x >> 16)) * 0x45d9f3b & 0x7FFFFFFF;
    x = (x ^ (x >> 16)) * 0x45d9f3b & 0x7FFFFFFF;
    return x ^ (x >> 16);
  }

  int _seedFor(String channel, int day) {
    var hash = day * 31 + channel.hashCode;
    hash = hash * 31 + packVersion.hashCode;
    return _mix(hash);
  }

  /// Picks an index without repetition inside one cycle of the pool.
  ///
  /// A naive modulo of a random number repeats an item roughly every
  /// forty days on a pool of a thousand, and users notice repeats far
  /// more than they notice novelty. Walking a permuted cycle means no
  /// item recurs until every item has been shown.
  int indexFor({
    required String channel,
    required int poolSize,
    required int day,
  }) {
    assert(poolSize > 0, 'empty pool for $channel');
    final cycle = day ~/ poolSize;
    final offset = day % poolSize;
    final rotation = _mix(_seedFor(channel, cycle)) % poolSize;
    // A coprime stride permutes the cycle without a shuffle buffer.
    final stride = _coprimeStride(poolSize, _seedFor(channel, cycle));
    return (rotation + offset * stride) % poolSize;
  }

  static int _coprimeStride(int n, int seed) {
    if (n <= 2) return 1;
    var candidate = (seed % (n - 1)).abs() + 1;
    while (_gcd(candidate, n) != 1) {
      candidate = candidate % (n - 1) + 1;
    }
    return candidate;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// The dua is the only contextual choice, and context here means the
  /// clock and the calendar. Nothing about the user's behaviour enters
  /// this function.
  DuaOccasion occasionFor({
    required DateTime localNow,
    required bool isFriday,
    required bool isRamadan,
  }) {
    if (isRamadan) return DuaOccasion.ramadan;
    if (isFriday) return DuaOccasion.friday;

    final hour = localNow.hour;
    if (hour < 10) return DuaOccasion.morning;
    if (hour >= 21) return DuaOccasion.beforeSleep;
    if (hour >= 16) return DuaOccasion.evening;
    return DuaOccasion.general;
  }
}

/// On-device personalisation, tiered.
///
/// Tier 0 is the default and it is the whole product for most users.
/// Nothing above tier 0 ever leaves the device, and no tier infers
/// religiosity from behaviour.
enum PersonalisationTier {
  /// Date and pack version only. Everyone on the same day sees the
  /// same verse.
  none,

  /// Time of day, Hijri date, locale. Derived from the clock, not from
  /// the user. Cannot be turned off because it is not profiling.
  contextual,

  /// Topics the user explicitly selected in settings, and a hard
  /// exclusion list. Stored locally, never synced, never sent.
  declared,
}

/// The line this app does not cross.
///
/// Behavioural inference is deliberately not a tier. Selecting content
/// from what somebody reads, how often they pray, or which verses they
/// linger on means building a profile of religious practice, which is
/// special category data under Article 9. The app's stated promise is
/// that reading history never reaches the server, and a recommender is
/// the most likely thing to quietly break that promise.
const kBehaviouralInferenceIsNotSupported = true;
