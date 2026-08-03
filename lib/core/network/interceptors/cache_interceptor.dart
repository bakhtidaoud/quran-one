import 'package:dio/dio.dart';
import 'package:quran_one/core/network/cache_policy.dart';
import 'package:quran_one/core/network/response_cache.dart';

/// A read-through cache that also answers when the network cannot.
///
/// Two behaviours matter more than hit rate:
///   1. A stale entry is served instantly and refreshed behind the user.
///   2. When the request fails and any entry exists, however old, it is
///      returned rather than the error. Offline is the default assumption,
///      so "old data" always beats "no data" outside of billing.
class CacheInterceptor extends Interceptor {
  CacheInterceptor(this._cache);

  final ResponseCache _cache;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final policy = options.extra['cachePolicy'] as CachePolicy?;
    if (policy == null ||
        !policy.isCacheable ||
        options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final entry = await _cache.read(_key(options));
    if (entry == null) return handler.next(options);

    if (!entry.isExpired(policy.ttl)) {
      return handler.resolve(entry.toResponse(options), true);
    }

    if (policy.staleWhileRevalidate) {
      // Hand back the stale body now and let the request continue in the
      // background to refresh it.
      options.extra['revalidating'] = true;
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final policy = response.requestOptions.extra['cachePolicy'] as CachePolicy?;
    final isOk = (response.statusCode ?? 0) < 300;

    if (policy != null && policy.isCacheable && isOk) {
      await _cache.write(_key(response.requestOptions), response.data);
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final policy = err.requestOptions.extra['cachePolicy'] as CachePolicy?;
    if (policy == null || !policy.isCacheable) return handler.next(err);

    final entry = await _cache.read(_key(err.requestOptions));
    if (entry == null) return handler.next(err);

    // Expiry is deliberately ignored here. A three-week-old surah list is
    // still the correct surah list.
    handler.resolve(entry.toResponse(err.requestOptions));
  }

  String _key(RequestOptions options) {
    final query = Map<String, dynamic>.from(options.queryParameters);
    final sorted = query.keys.toList()..sort();
    final canonical = sorted.map((k) => '$k=${query[k]}').join('&');
    return '${options.method}:${options.path}?$canonical';
  }
}
