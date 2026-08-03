import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/features/quran/data/repositories/ayah_repository_impl.dart';
import 'package:quran_one/features/quran/data/repositories/reading_position_repository_impl.dart';
import 'package:quran_one/features/quran/data/repositories/translation_repository_impl.dart';
import 'package:quran_one/features/quran/data/sources/ayah_local_source.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/usecases/get_annotated_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'di.g.dart';

// The composition root.
//
// This is the only file in the codebase where an interface meets its
// implementation. An architecture test asserts that every repository
// interface has exactly one binding here and that no binding lives inside a
// feature folder.
//
// Every provider returns the INTERFACE type, never the *Impl. If a provider
// returned AyahRepositoryImpl, every consumer would take a dependency on the
// data layer and the layering lint would fire.

// --- Sources -----------------------------------------------------------

@Riverpod(keepAlive: true)
AyahLocalSource ayahLocalSource(Ref ref) => AyahLocalSource();

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
// autoDispose by default. Use cases are cheap glue objects; keeping them
// alive buys nothing and hides lifecycle bugs.

@riverpod
GetAnnotatedRange getAnnotatedRange(Ref ref) => GetAnnotatedRange(
      ref.watch(ayahRepositoryProvider),
      ref.watch(translationRepositoryProvider),
    );
