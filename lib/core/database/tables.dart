import 'package:drift/drift.dart';

/// Where the user last stopped reading, per mode.
///
/// One row per reading mode so that mushaf position and translation-list
/// position do not overwrite each other.
class ReadingPositions extends Table {
  TextColumn get mode => text()();
  IntColumn get surah => integer()();
  IntColumn get ayah => integer()();
  IntColumn get page => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {mode};
}

/// User bookmarks. Synced.
class Bookmarks extends Table {
  TextColumn get id => text()();
  IntColumn get surah => integer()();
  IntColumn get ayah => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get highlightColor => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Spaced-repetition state for memorisation.
///
/// Never overwritten by a sync pull without conflict resolution: losing
/// review history is AR-3 and is worse than losing any other data in the app.
class HifzCards extends Table {
  TextColumn get id => text()();
  IntColumn get surah => integer()();
  IntColumn get ayah => integer()();
  RealColumn get ease => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local queue of changes awaiting upload. Survives process death.
class OutboxEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Installed content packs: translations, tafsir, recitations, mushaf fonts.
class ContentPacks extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get version => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get checksum => text()();
  DateTimeColumn get installedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
