import 'package:dio/dio.dart';
import 'package:quran_one/core/error/q_failure.dart';

/// Translates the Django error envelope into the sealed QFailure hierarchy.
///
/// The server emits exactly one failure shape:
///   {"error": {"code": "...", "message": "...", "trace_id": "..."}}
/// This file is the only place that knows that. Adding a code on the Django
/// side without adding it here is a breaking change, which is why the codes
/// are exhaustively switched rather than looked up in a map.
class ErrorMapper {
  const ErrorMapper();

  QFailure fromDio(DioException e) {
    final response = e.response;

    if (response == null) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const TimeoutFailure('The server took too long to respond'),
        DioExceptionType.connectionError =>
          const NetworkFailure('No connection'),
        DioExceptionType.cancel => const NetworkFailure('Request cancelled'),
        _ => UnknownFailure(e.message ?? 'Request failed'),
      };
    }

    return fromResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data,
      retryAfterHeader: response.headers.value('retry-after'),
    );
  }

  QFailure fromResponse({
    required int statusCode,
    required Object? body,
    String? retryAfterHeader,
  }) {
    final envelope = _envelope(body);
    final code = envelope?['code'] as String?;
    final message = envelope?['message'] as String? ?? 'Request failed';
    final traceId = envelope?['trace_id'] as String?;

    // Code first, status second. The status tells you the category; the
    // code tells you what actually happened, and only one of those is
    // stable enough to branch on.
    return switch (code) {
      'validation_failed' => ValidationFailure(
          message,
          traceId: traceId,
          field: _firstField(envelope),
        ),
      'unauthorized' => UnauthorizedFailure(message, traceId: traceId),
      'forbidden' => PermissionFailure(message, traceId: traceId),
      'not_found' => ServerFailure(
          message,
          statusCode: 404,
          type: 'not_found',
          traceId: traceId,
        ),
      'conflict' => SyncConflictFailure(message, traceId: traceId),
      'rate_limited' => RateLimitedFailure(
          message,
          traceId: traceId,
          retryAfter: _retryAfter(envelope, retryAfterHeader),
        ),
      'server_error' => ServerFailure(
          message,
          statusCode: statusCode,
          type: 'server_error',
          traceId: traceId,
        ),
      _ => _fromStatus(statusCode, message, traceId),
    };
  }

  QFailure _fromStatus(int status, String message, String? traceId) =>
      switch (status) {
        401 => UnauthorizedFailure(message, traceId: traceId),
        403 => PermissionFailure(message, traceId: traceId),
        409 => SyncConflictFailure(message, traceId: traceId),
        429 => RateLimitedFailure(
            message,
            traceId: traceId,
            retryAfter: const Duration(seconds: 60),
          ),
        >= 500 => ServerFailure(
            message,
            statusCode: status,
            type: 'server_error',
            traceId: traceId,
          ),
        _ => UnknownFailure(message, traceId: traceId),
      };

  Map<String, dynamic>? _envelope(Object? body) {
    if (body is! Map) return null;
    final error = body['error'];
    return error is Map ? Map<String, dynamic>.from(error) : null;
  }

  String? _firstField(Map<String, dynamic>? envelope) {
    final fields = envelope?['fields'];
    if (fields is Map && fields.isNotEmpty) return fields.keys.first as String;
    return null;
  }

  Duration _retryAfter(Map<String, dynamic>? envelope, String? header) {
    final fromBody = envelope?['retry_after'];
    if (fromBody is num) return Duration(seconds: fromBody.round());
    final fromHeader = int.tryParse(header ?? '');
    // Never zero. A retry_after of zero turns a rate limit into a tight
    // loop against the endpoint that just asked you to slow down.
    return Duration(seconds: fromHeader ?? 60);
  }
}
