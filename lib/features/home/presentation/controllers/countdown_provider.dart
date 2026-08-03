import 'package:quran_one/features/home/presentation/controllers/countdown.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'countdown_provider.g.dart';

/// A tick stream whose interval follows the displayed precision.
///
/// Ticking once a second all day is wrong: it is a wakeup per second
/// for a display that changes once a minute, and it runs while the
/// card sits on screen waiting. Above five minutes this fires 60x less
/// often.
///
/// autoDispose is essential. A timer that survives navigation to the
/// Read tab is a timer running behind the reader forever. On
/// background, SessionWatcher pauses emission.
@riverpod
Stream<DateTime> clockTick(Ref ref) async* {
  var precision = CountdownPrecision.hoursMinutes;

  while (true) {
    yield DateTime.now();
    await Future<void>.delayed(precision.tick);
    // read, not watch: rebuilding the stream on every tick would
    // restart the subscription and drop a frame at the boundary.
    precision = ref.read(countdownProvider).precision;
  }
}

/// Derived countdown. Rebuilds only when the DateTime changes, which
/// the stream controls.
///
/// Phantom: nothing populates prayerTimesProvider yet. The provider
/// compiles; it returns a placeholder until prayer times are wired.
@riverpod
Countdown countdown(Ref ref) {
  final now = ref.watch(clockTickProvider).valueOrNull ?? DateTime.now();
  // TODO(batch-p): wire prayerTimesProvider once prayer module lands.
  // For now, return a stub so the card renders without crashing.
  return Countdown.resolve(times: const [], now: now);
}
