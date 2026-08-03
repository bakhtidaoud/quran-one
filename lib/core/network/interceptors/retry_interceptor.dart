import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Retries only what is safe to retry.
///
/// Idempotent methods and connection failures, three attempts, exponential
/// backoff with jitter. A POST is never retried automatically: replaying a
/// purchase or a sync push is worse than failing it.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {Random? random})
      : _random = random ?? Random();

  final Dio _dio;
  final Random _random;

  static const _maxAttempts = 3;
  static const _idempotent = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra['attempt'] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt + 1 >= _maxAttempts) {
      return handler.next(err);
    }

    await Future<void>.delayed(_backoff(attempt));

    options.extra['attempt'] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (!_idempotent.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => (err.response?.statusCode ?? 0) >= 500,
    };
  }

  Duration _backoff(int attempt) {
    final base = 400 * pow(2, attempt).toInt();
    // Jitter, so that a fleet of devices coming back online after an outage
    // does not arrive as a single synchronised wave.
    return Duration(milliseconds: base + _random.nextInt(300));
  }
}
