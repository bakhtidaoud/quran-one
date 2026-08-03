import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_one/app/app.dart';
import 'package:quran_one/app/flavour.dart';
import 'package:quran_one/app/observers.dart';
import 'package:quran_one/app/startup/startup_task.dart';
import 'package:quran_one/app/startup/tasks/database_task.dart';
import 'package:quran_one/app/startup/tasks/preferences_task.dart';
import 'package:quran_one/app/startup/tasks/timezone_task.dart';
import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/core/logging/logger.dart';
import 'package:quran_one/core/storage/preferences.dart';

/// The single startup path for all three flavours.
///
/// Exactly three tasks block the first frame. Everything else runs after the
/// app is on screen.
Future<void> bootstrap({
  required Flavour flavour,
  required AppConfig config,
}) async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  binding.deferFirstFrame();

  await runZonedGuarded(
    () async {
      FlutterError.onError = (details) {
        QLog.instance.error(
          'flutter error',
          details.exception,
          details.stack,
        );
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        QLog.instance.error('platform error', error, stack);
        return true;
      };

      final ctx = StartupContext(flavour: flavour, config: config);

      const blocking = <StartupTask>[];
      final tasks = <StartupTask>[
        PreferencesTask(),
        DatabaseTask(),
        TimezoneTask(),
        ...blocking,
      ];

      for (final task in tasks) {
        final sw = Stopwatch()..start();
        await task.run(ctx);
        sw.stop();
        QLog.instance.debug('startup.${task.name} ${sw.elapsedMilliseconds}ms');
      }

      binding.allowFirstFrame();

      runApp(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(ctx.preferences!),
            appDatabaseProvider.overrideWithValue(ctx.database!),
            appConfigProvider.overrideWithValue(config),
            flavourProvider.overrideWithValue(flavour),
          ],
          observers: [QProviderObserver()],
          child: const QuranOneApp(),
        ),
      );
    },
    (error, stack) => QLog.instance.error('zone error', error, stack),
  );
}
