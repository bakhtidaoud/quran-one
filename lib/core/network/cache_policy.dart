import 'package:dio/dio.dart';

/// How long a response stays usable, by kind of data.
///
/// Scripture is immutable, so it is cached effectively forever. Prayer
/// calculation methods change when a committee meets, which is roughly
/// never. Entitlement is never cached, because a stale premium answer is
/// either a refund request or a free ride.
enum CachePolicy {
  scripture(Duration(days: 3650), staleWhileRevalidate: false),
  reference(Duration(days: 7)),
  catalogue(Duration(hours: 12)),
  userData(Duration(minutes: 5)),
  never(Duration.zero, staleWhileRevalidate: false);

  const CachePolicy(this.ttl, {this.staleWhileRevalidate = true});

  final Duration ttl;

  /// Serve the stale copy immediately, refresh in the background.
  ///
  /// This is the default because the alternative, blocking the UI on a
  /// revalidation round trip, makes a fast app feel slow on exactly the
  /// networks most of our users are on.
  final bool staleWhileRevalidate;

  bool get isCacheable => ttl > Duration.zero;
}

extension CachePolicyOptions on Options {
  static Options of(CachePolicy policy, {bool anonymous = false}) => Options(
        extra: {
          'cachePolicy': policy,
          if (anonymous) 'anonymous': true,
        },
      );
}
