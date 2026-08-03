import 'package:quran_one/app/startup/startup_task.dart';
import 'package:quran_one/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Blocking. The theme mode and locale are read before the first frame,
/// otherwise the app flashes the wrong theme on every cold start.
class PreferencesTask implements StartupTask {
  @override
  String get name => 'preferences';

  @override
  bool get isBlocking => true;

  @override
  Future<void> run(StartupContext ctx) async {
    final raw = await SharedPreferences.getInstance();
    ctx.preferences = Preferences(raw);
  }
}
