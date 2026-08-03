import 'package:dio/dio.dart';
import 'package:quran_one/app/flavour.dart';
import 'package:quran_one/core/network/interceptors/auth_interceptor.dart';
import 'package:quran_one/core/network/interceptors/retry_interceptor.dart';
import 'package:quran_one/core/network/interceptors/trace_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

/// The HTTP client, built once.
///
/// keepAlive because a Dio instance owns a connection pool. Recreating it
/// per screen throws away every warm TLS connection, which on a slow network
/// is the difference between an instant response and a second of handshake.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);

  final client = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      // Generous, because the target audience includes 3G in places where
      // 3G is the good option.
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      // Do not throw on 4xx. The repository layer maps status codes onto
      // QFailure; an exception for an expected 404 is control flow by
      // panic.
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  client.interceptors.addAll([
    TraceInterceptor(),
    ref.watch(authInterceptorProvider),
    RetryInterceptor(client),
  ]);

  ref.onDispose(client.close);

  return client;
}
