import 'package:flutter/foundation.dart';

/// Crash reporting behind an interface, so the domain never imports
/// Firebase and tests never initialise a native SDK.
abstract interface class CrashReporter {
  Future<void> initialise({required String flavour});
  Future<void> record(Object error, StackTrace stack, {bool fatal});
  void breadcrumb(String message, {Map<String, Object?> data});
  Future<void> setUser(String? anonymousId);
}

/// The default in dev and in tests. Prints and forgets.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> initialise({required String flavour}) async {}

  @override
  Future<void> record(Object error, StackTrace stack, {bool fatal = false}) async {
    if (kDebugMode) debugPrint('crash: $error\n$stack');
  }

  @override
  void breadcrumb(String message, {Map<String, Object?> data = const {}}) {}

  @override
  Future<void> setUser(String? anonymousId) async {}
}

/// Keys whose values must never leave the device.
///
/// Mirrors REDACTED_KEYS in the Django logger. A crash report that carries
/// a coordinate, a bookmark note, or a search query has turned an
/// engineering tool into a surveillance one. Religious reading history is
/// among the most sensitive data a person has, and in some jurisdictions
/// it is dangerous.
const redactedKeys = <String>{
  'password',
  'token',
  'refresh',
  'access',
  'authorization',
  'latitude',
  'longitude',
  'email',
  'note',
  'query',
};

Map<String, Object?> redact(Map<String, Object?> input) => {
      for (final entry in input.entries)
        entry.key: redactedKeys.contains(entry.key.toLowerCase())
            ? '[redacted]'
            : entry.value,
    };
