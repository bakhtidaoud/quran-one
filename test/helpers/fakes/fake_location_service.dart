import 'dart:async';

import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/shared/domain/services/location_service.dart';

/// A fake, not a mock.
///
/// It implements the interface, so changing the interface breaks this file
/// at compile time. A mock would keep compiling and start returning null in
/// production six months later.
class FakeLocationService implements LocationService {
  FakeLocationService({
    CoarseLocation? location,
    this.permissionGranted = true,
    this.permanentlyDenied = false,
  }) : location = location ??
            CoarseLocation(latitude: 33.5731, longitude: -7.5898);

  final CoarseLocation location;
  bool permissionGranted;
  bool permanentlyDenied;

  int currentCallCount = 0;
  final _controller = StreamController<CoarseLocation>.broadcast();

  void emit(CoarseLocation next) => _controller.add(next);

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<Result<bool, QFailure>> requestPermission() async {
    if (permanentlyDenied) {
      return const Err(
        PermissionFailure('denied forever', permanentlyDenied: true),
      );
    }
    return Ok(permissionGranted);
  }

  @override
  Future<Result<CoarseLocation, QFailure>> current() async {
    currentCallCount++;
    if (!permissionGranted) {
      return const Err(PermissionFailure('no permission'));
    }
    return Ok(location);
  }

  @override
  Future<Result<CoarseLocation, QFailure>> lastKnown() async => Ok(location);

  @override
  Stream<CoarseLocation> watch() => _controller.stream;
}

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({bool online = true}) : _online = online;

  bool _online;
  final _controller = StreamController<bool>.broadcast();

  void goOffline() {
    _online = false;
    _controller.add(false);
  }

  void goOnline() {
    _online = true;
    _controller.add(true);
  }

  @override
  Future<bool> get isOnline async => _online;

  @override
  Stream<bool> get changes => _controller.stream;
}
