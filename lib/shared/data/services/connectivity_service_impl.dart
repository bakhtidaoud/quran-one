import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quran_one/shared/domain/services/location_service.dart';

class PlatformConnectivityService implements ConnectivityService {
  PlatformConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async => _isOnline(
        await _connectivity.checkConnectivity(),
      );

  @override
  Stream<bool> get changes =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();

  // Reachability, not truth. A captive portal reports connected. Nothing in
  // this app blocks on this answer; it only decides whether to attempt a
  // sync now or queue it.
  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
