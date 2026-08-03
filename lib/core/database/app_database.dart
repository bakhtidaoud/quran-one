import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:quran_one/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// The local store. Source of truth for every read (P1: offline by default).
///
/// The network is an update mechanism, never a read path.
@DriftDatabase(
  tables: [
    ReadingPositions,
    Bookmarks,
    HifzCards,
    OutboxEntries,
    ContentPacks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'quran_one'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Migration steps are added one file at a time under
          // core/database/migrations/steps and dispatched here. Each step is
          // covered by a schema test before it ships.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Forces the lazy connection open so that migrations run inside the timed
  /// startup task rather than on the first query from a screen.
  Future<void> warmUp() => customSelect('SELECT 1').get();
}

/// Root provider. Overridden in bootstrap.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) =>
    throw UnimplementedError('appDatabaseProvider must be overridden');
