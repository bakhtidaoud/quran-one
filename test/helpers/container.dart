import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/app/di.dart';
import 'package:quran_one/app/flavour.dart';
import 'package:quran_one/core/database/app_database.dart';

import 'fakes/fake_location_service.dart';

/// The single place a test container is built.
///
/// This exists so that adding a fourth root override is a one-file change
/// rather than a ninety-file one. Every test that needs a container calls
/// this and overrides only what it actually cares about.
ProviderContainer makeContainer({
  List<Override> overrides = const [],
  AppDatabase? database,
}) {
  final db = database ?? AppDatabase.forTesting(NativeDatabase.memory());

  final container = ProviderContainer(
    overrides: [
      // The three that bootstrap() supplies in production.
      appDatabaseProvider.overrideWithValue(db),
      appConfigProvider.overrideWithValue(const AppConfig.test()),
      flavourProvider.overrideWithValue(Flavour.dev),

      // Platform capabilities. Overridden by default rather than on
      // request: a unit test that silently reaches for the real GPS is a
      // test that passes on a developer laptop and hangs in CI.
      locationServiceProvider.overrideWithValue(FakeLocationService()),
      connectivityServiceProvider.overrideWithValue(FakeConnectivityService()),

      ...overrides,
    ],
  );

  addTearDown(container.dispose);
  addTearDown(db.close);

  return container;
}
