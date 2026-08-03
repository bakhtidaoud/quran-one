import 'package:dio/dio.dart';
import 'package:quran_one/core/network/cache_policy.dart';

/// The refresh exchange, deliberately on its own Dio instance.
///
/// Using the main client here would send the request through
/// AuthInterceptor, which would attach the expired access token and, on
/// failure, try to refresh, which would call this method again. That is an
/// infinite loop that only appears once a token has actually expired in
/// production.
class AuthApi {
  AuthApi({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  final Dio _dio;

  /// Returns a new access token, or null when the refresh token is dead.
  ///
  /// Null is the signal to clear credentials and fall back to anonymous
  /// mode. It is not the signal to show a login wall: the user keeps
  /// reading, and only the three protected routes become unavailable.
  Future<String?> exchange(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh': refreshToken},
        options: CachePolicyOptions.of(CachePolicy.never, anonymous: true),
      );
      return response.data?['access'] as String?;
    } on DioException {
      return null;
    }
  }
}
