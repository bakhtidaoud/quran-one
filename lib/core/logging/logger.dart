import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Structured logging. `print` is banned by lint.
///
/// Production keeps warning and above; debug builds keep everything.
class QLog {
  QLog._(this._logger);

  static final QLog instance = QLog._(
    Logger(
      level: kDebugMode ? Level.debug : Level.warning,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        colors: false,
        printEmojis: false,
      ),
    ),
  );

  final Logger _logger;

  void debug(String message) => _logger.d(message);

  void info(String message) => _logger.i(message);

  void warn(String message, [Object? error, StackTrace? stack]) =>
      _logger.w(message, error: error, stackTrace: stack);

  void error(String message, [Object? error, StackTrace? stack]) =>
      _logger.e(message, error: error, stackTrace: stack);
}
