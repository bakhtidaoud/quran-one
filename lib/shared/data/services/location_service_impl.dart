import 'package:geolocator/geolocator.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/shared/domain/services/location_service.dart';

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<Result<bool, QFailure>> requestPermission() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      // Distinguished from a plain denial, because the UI must stop asking
      // and offer manual city entry instead. Nagging is how apps get
      // uninstalled.
      return const Err(PermissionFailure(
        'Location permission permanently denied',
        permanentlyDenied: true,
      ));
    }

    return Ok(
      permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse,
    );
  }

  @override
  Future<Result<CoarseLocation, QFailure>> current() async {
    if (!await hasPermission()) {
      return const Err(PermissionFailure('Location permission not granted'));
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Low accuracy on purpose. It is faster, it costs far less
          // battery, and it is already more precise than the use case
          // requires.
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return Ok(
        CoarseLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on Object catch (e) {
      return Err(UnknownFailure('Location lookup failed: $e'));
    }
  }

  @override
  Future<Result<CoarseLocation, QFailure>> lastKnown() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) {
      return const Err(CacheFailure('No cached location'));
    }
    return Ok(
      CoarseLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  @override
  Stream<CoarseLocation> watch() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          // Prayer times do not change meaningfully over 500 metres. This
          // filter is the difference between a 2%/hour battery cost and a
          // 20% one.
          distanceFilter: 500,
        ),
      ).map(
        (p) => CoarseLocation(latitude: p.latitude, longitude: p.longitude),
      );
}
