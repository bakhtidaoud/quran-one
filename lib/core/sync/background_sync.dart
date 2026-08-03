import 'package:flutter/foundation.dart';

/// Background sync registration and, more importantly, its limits.
///
/// Background sync is OPPORTUNISTIC. Correctness must never depend on it.
/// This is logged as AR-2 and there are three independent reasons:
///
/// 1. Xiaomi, Huawei, Oppo, Vivo and Samsung aggressively terminate
///    background work for apps the user has not manually whitelisted. In
///    Indonesia, Pakistan, Bangladesh and Egypt -- four of this app's
///    largest expected markets -- those OEMs are the majority of devices.
/// 2. iOS BGAppRefreshTask is scheduled from usage heuristics. An app
///    opened once a week may receive one refresh a week, or none.
/// 3. Doze batches all deferred work into maintenance windows that can be
///    hours apart.
///
/// Therefore every sync trigger that matters is a FOREGROUND trigger: on
/// resume, on connectivity regained, and on explicit pull-to-refresh.
/// Background work only reduces how much the foreground sync has to do.
@immutable
class BackgroundSyncPolicy {
  const BackgroundSyncPolicy({
    this.interval = const Duration(hours: 6),
    this.requiresNetwork = true,
    this.requiresBatteryNotLow = true,
  });

  /// The OS treats this as a suggestion, never a contract.
  final Duration interval;

  final bool requiresNetwork;

  /// Sync is never worth a percent of someone's remaining battery. The
  /// data is a bookmark list, and it will still be there at the charger.
  final bool requiresBatteryNotLow;

  static const taskName = 'quran_one.sync';
}

/// Foreground triggers, in priority order. These are the ones that must
/// work.
enum SyncTrigger {
  /// App resumed from background.
  appResume,

  /// ConnectivityService reported a transition to online. The outbox
  /// controller already listens for this.
  connectivityRegained,

  /// Explicit pull-to-refresh, or the "Sync now" row in Settings.
  ///
  /// That row should never be necessary, and it belongs in the product
  /// anyway: it is the cheapest support tool this team will ever build,
  /// and its absence turns every sync question into a reinstall.
  manual,

  /// Opportunistic, may never fire. See above.
  background,
}
