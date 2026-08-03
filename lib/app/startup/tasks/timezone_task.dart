import 'package:quran_one/app/startup/startup_task.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Blocking and non-negotiable.
///
/// Scheduling an athan across a DST boundary without an initialised timezone
/// database silently fires prayers an hour off. That is AR-2 and it is not
/// recoverable at runtime.
class TimezoneTask implements StartupTask {
  @override
  String get name => 'timezone';

  @override
  bool get isBlocking => true;

  @override
  Future<void> run(StartupContext ctx) async {
    tzdata.initializeTimeZones();
    // The device zone is resolved lazily per notification, not cached here,
    // because a traveller can cross zones while the process stays alive.
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
}
