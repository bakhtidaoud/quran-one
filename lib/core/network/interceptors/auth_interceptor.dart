import 'dart:async';

import 'package:dio/dio.dart';
import 'package:quran_one/core/storage/token_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(Ref ref) =>
    AuthInterceptor(ref.watch(tokenStoreProvider));

/// Attaches the access token and refreshes it exactly once per expiry.
///
/// The single-flight lock matters: without it, six parallel requests that
/// all see a 401 will fire six refreshes, and five of them will fail against
/// a server that rotates refresh tokens.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokens);

  final TokenStore _tokens;
  Future<String?>? _inFlightRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['anonymous'] == true) {
      return handler.next(options);
    }

    final token = await _tokens.accessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retriedAuth'] == true;

    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await (_inFlightRefresh ??= _refresh());
    _inFlightRefresh = null;

    if (refreshed == null) {
      await _tokens.clear();
      return handler.next(err);
    }

    final options = err.requestOptions
      ..extra['retriedAuth'] = true
      ..headers['Authorization'] = 'Bearer $refreshed';

    try {
      final response = await Dio().fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refresh() async {
    final refresh = await _tokens.refreshToken();
    if (refresh == null) return null;
    return _tokens.exchange(refresh);
  }
}
