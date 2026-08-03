import 'package:flutter/material.dart';
import 'package:quran_one/app/observability/crash_reporter.dart';

/// Replaces the grey-and-red error box with something a person can act on.
///
/// The default ErrorWidget is a debugging aid that ships to production by
/// accident in a large share of Flutter apps. In release it shows a solid
/// grey rectangle, which users read as "the app is broken" rather than
/// "this one card failed".
void installErrorBoundary(CrashReporter reporter) {
  ErrorWidget.builder = (details) {
    reporter.record(
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: false,
    );
    return const _FailedSection();
  };
}

class _FailedSection extends StatelessWidget {
  const _FailedSection();

  @override
  Widget build(BuildContext context) {
    // Deliberately minimal and theme-agnostic. This widget renders when
    // something has already gone wrong, so it must not depend on a theme
    // extension that may itself be the thing that failed.
    return const Padding(
      padding: EdgeInsetsDirectional.all(16),
      child: Text(
        'This section could not be shown.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
