import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/app/flavour.dart';
import 'package:quran_one/core/database/app_database.dart';

/// One place that defines what a test environment looks like.
///
/// Widget tests and container tests share these defaults, so adding a fourth
/// root provider means changing one file rather than ninety.
ProviderContainer makeContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
      appConfigProvider.overrideWithValue(const AppConfig.test()),
      flavourProvider.overrideWithValue(Flavour.dev),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}
