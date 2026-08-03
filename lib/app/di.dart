import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/core/network/dio_client.dart';
import 'package:quran_one/features/quran/data/repositories/ayah_repository_impl.dart';
import 'package:quran_one/features/quran/data/repositories/reading_position_repository_impl.dart';
import 'package:quran_one/features/quran/data/repositories/translation_repository_impl.dart';
import 'package:quran_one/features/quran/data/sources/ayah_local_source.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/usecases/get_annotated_range.dart';
import 'package:quran_one/shared/data/services/connectivity_service_impl.dart';
import 'package:quran_one/shared/data/services/location_service_impl.dart';
import 'package:quran_one/shared/domain/services/location_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'di.g.dart';

// The composition root.
//
// This is the only file in the codebase where an interface meets its
// implementation. Two architecture tests depend on that being true:
// every repository interface has exactly one binding here, and no provider
// anywhere returns a concrete *Impl type.
//
// Read this file top to bottom and you know what the app is made of.

// --- Sources -----------------------------------------------------------

@Riverpod(keepAlive: true)
AyahLocalSource ayahLocalSource(Ref ref) => AyahLocalSource();

// --- Services ----------------------------------------------------------
//
// A service wraps a capability the platform owns. A repository owns state
// the app is the source of truth for. Location is the platform's; bookmarks
// are ours.

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => const GeolocatorLocationService();

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) =>
    PlatformConnectivityService(Connectivity());

// --- Repositories ------------------------------------------------------

@Riverpod(keepAlive: true)
AyahRepository ayahRepository(Ref ref) => AyahRepositoryImpl(
      local: ref.watch(ayahLocalSourceProvider),
    );

@Riverpod(keepAlive: true)
TranslationRepository translationRepository(Ref ref) =>
    TranslationRepositoryImpl(db: ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ReadingPositionRepository readingPositionRepository(Ref ref) =>
    ReadingPositionRepositoryImpl(db: ref.watch(appDatabaseProvider));

// --- Use cases ---------------------------------------------------------
//
// autoDispose, deliberately. A use case is a cheap glue object holding no
// state; keeping one alive buys nothing and hides lifecycle bugs.

@riverpod
GetAnnotatedRange getAnnotatedRange(Ref ref) => GetAnnotatedRange(
      ref.watch(ayahRepositoryProvider),
      ref.watch(translationRepositoryProvider),
    );

// --- Sanity ------------------------------------------------------------

/// Every keepAlive dependency, in one list, so a test can resolve them all
/// and prove the graph has no missing override and no cycle.
///
/// Adding a keepAlive provider without adding it here is caught by
/// `test/architecture/di_test.dart`.
final rootDependencies = <ProviderListenable<Object?>>[
  dioProvider,
  appDatabaseProvider,
  ayahLocalSourceProvider,
  locationServiceProvider,
  connectivityServiceProvider,
  ayahRepositoryProvider,
  translationRepositoryProvider,
  readingPositionRepositoryProvider,
];
