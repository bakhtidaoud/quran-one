import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';

/// A coordinate, already coarsened.
///
/// There is no constructor that accepts full precision. Three decimal places
/// is roughly 110 metres, which is far more accuracy than a prayer time or a
/// qibla bearing needs, and far less than is needed to identify a home.
class CoarseLocation {
  CoarseLocation({required double latitude, required double longitude})
      : latitude = _round(latitude),
        longitude = _round(longitude);

  final double latitude;
  final double longitude;

  static double _round(double value) => (value * 1000).roundToDouble() / 1000;

  @override
  bool operator ==(Object other) =>
      other is CoarseLocation &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'CoarseLocation($latitude, $longitude)';
}

/// A service, not a repository.
///
/// The distinction that matters: a repository owns persisted state the app
/// is the source of truth for. A service wraps a capability the platform
/// owns. Location is the platform's; the app only borrows it.
abstract interface class LocationService {
  Future<Result<CoarseLocation, QFailure>> current();
  Future<Result<CoarseLocation, QFailure>> lastKnown();
  Stream<CoarseLocation> watch();
  Future<bool> hasPermission();
  Future<Result<bool, QFailure>> requestPermission();
}

/// Network reachability, as a capability rather than a global.
abstract interface class ConnectivityService {
  Future<bool> get isOnline;
  Stream<bool> get changes;
}
