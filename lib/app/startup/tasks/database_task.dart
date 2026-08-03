import 'package:quran_one/app/startup/startup_task.dart';
import 'package:quran_one/core/database/app_database.dart';

/// Blocking. Opening SQLite costs roughly 40ms.
///
/// Paying that before the first frame is cheaper than threading AsyncValue
/// through fifteen features forever.
class DatabaseTask implements StartupTask {
  @override
  String get name => 'database';

  @override
  bool get isBlocking => true;

  @override
  Future<void> run(StartupContext ctx) async {
    final db = AppDatabase();
    // Force the lazy connection open so migrations run inside the timed task
    // rather than on the first query from a screen.
    await db.warmUp();
    ctx.database = db;
  }
}
