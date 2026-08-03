import 'package:quran_one/app/flavour.dart';
import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/core/storage/preferences.dart';

/// Mutable carrier passed through the startup sequence.
///
/// Blocking tasks populate the fields that bootstrap later injects as root
/// provider overrides.
class StartupContext {
  StartupContext({required this.flavour, required this.config});

  final Flavour flavour;
  final AppConfig config;

  Preferences? preferences;
  AppDatabase? database;
}

/// One unit of application startup.
///
/// Modelling startup as discrete tasks rather than one bootstrap function is
/// what makes the 2.0s cold-start budget measurable: each task is timed
/// individually and appears by name in the trace.
abstract interface class StartupTask {
  /// Short identifier used as the trace key, e.g. `startup.database`.
  String get name;

  /// When false the task runs after the first frame and cannot delay launch.
  bool get isBlocking;

  Future<void> run(StartupContext ctx);
}
