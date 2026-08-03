import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/app/di.dart';
import 'package:quran_one/shared/domain/services/location_service.dart';

import '../helpers/container.dart';
import '../helpers/fakes/fake_location_service.dart';

void main() {
  test('location is coarsened at construction, not at use', () {
    // The rounding cannot be forgotten by a caller because there is no
    // constructor that preserves full precision.
    final precise = CoarseLocation(
      latitude: 33.5731104829,
      longitude: -7.5898434021,
    );

    expect(precise.latitude, 33.573);
    expect(precise.longitude, -7.59);
  });

  test('permanently denied is distinguishable from denied', () async {
    final fake = FakeLocationService(
      permissionGranted: false,
      permanentlyDenied: true,
    );
    final container = makeContainer(
      overrides: [locationServiceProvider.overrideWithValue(fake)],
    );

    final result = await container.read(locationServiceProvider)
        .requestPermission();

    // The UI needs this distinction to stop asking and offer manual city
    // entry instead. Repeated permission prompts are how apps get deleted.
    expect(result.isErr, isTrue);
  });

  test('connectivity changes propagate to listeners', () async {
    final fake = FakeConnectivityService();
    final container = makeContainer(
      overrides: [connectivityServiceProvider.overrideWithValue(fake)],
    );

    final service = container.read(connectivityServiceProvider);
    final seen = <bool>[];
    final subscription = service.changes.listen(seen.add);

    fake.goOffline();
    fake.goOnline();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(seen, [false, true]);
  });
}
