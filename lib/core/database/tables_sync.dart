import 'package:drift/drift.dart';

/// Every local write that has not yet reached the server.
///
/// Durable by design. The queue is a table rather than an in-memory list,
/// so a force-quit mid-sync loses nothing and resumes on next launch.
class OutboxEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()(); // bookmark | hifz | position
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // upsert | delete
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get queuedAt => dateTime()();
  DateTimeColumn get deferUntil => dateTime().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        // One pending write per entity. A user who toggles a bookmark six
        // times offline should produce one row, not six round trips that
        // arrive out of order and leave the server in the wrong state.
        {entity, entityId},
      ];
}

/// Where the last successful pull stopped, per entity.
///
/// The value stored is the SERVER's clock, never the device's. Device
/// clocks are wrong often enough that a locally derived cursor eventually
/// skips a window of changes, permanently and silently.
class SyncCursors extends Table {
  TextColumn get entity => text()();
  DateTimeColumn get serverTime => dateTime().nullable()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {entity};
}

/// HTTP response cache, backing `SqliteResponseCache`.
///
/// On disk rather than in memory, because a memory cache is empty on every
/// cold start, which is exactly when a user on a bad connection needs it.
class CacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get body => text()();
  DateTimeColumn get storedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
