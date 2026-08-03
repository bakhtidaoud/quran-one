import 'dart:math';

import 'package:dio/dio.dart';
import 'package:quran_one/core/logging/logger.dart';

/// Sends an X-Request-ID and keeps it on the response.
///
/// When a user reports that something failed, the only useful question is
/// which request. The same id appears in the device log, the server log and
/// the error body, which turns an unanswerable report into a lookup.
class TraceInterceptor extends Interceptor {
  TraceInterceptor({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _traceHeader = 'X-Request-ID';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final traceId = _generate();
    options.headers[_traceHeader] = traceId;
    options.extra['traceId'] = traceId;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    QLog.instance.warn(
      'request failed',
      context: {
        'path': err.requestOptions.path,
        'status': err.response?.statusCode,
        'traceId': err.requestOptions.extra['traceId'],
      },
    );
    handler.next(err);
  }

  String _generate() {
    const chars = '0123456789abcdef';
    return List.generate(
      32,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }
}
