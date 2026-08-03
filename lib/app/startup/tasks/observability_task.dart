import 'package:flutter/foundation.dart';
import 'package:quran_one/app/observability/crash_reporter.dart';
import 'package:quran_one/app/startup/startup_task.dart';

/// Installs the global error handlers before anything can throw.
///
/// Non-blocking, but ordered first. Every task after this one is covered;
/// anything before it crashes silently, which is why there is nothing
/// before it.
class ObservabilityTask implements StartupTask {
  const ObservabilityTask(this._reporter);

  final CrashReporter _reporter;

  @override
  String get name => 'observability';

  @override
  bool get isBlocking => false;

  @override
  Future<void> run(StartupContext ctx) async {
    await _reporter.initialise(flavour: ctx.flavour.name);

    // Framework errors: overflow, build failures, layout assertions.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _reporter.record(
        details.exception,
        details.stack ?? StackTrace.current,
        fatal: false,
      );
    };

    // Everything the framework does not catch: platform channel failures,
    // async errors escaping an unawaited future. Without this handler they
    // vanish, which is how an app develops a reputation for "just closing
    // sometimes".
    PlatformDispatcher.instance.onError = (error, stack) {
      _reporter.record(error, stack, fatal: true);
      return true;
    };
  }
}
