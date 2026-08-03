import 'package:drift/drift.dart';
import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/core/database/tables_sync.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxEntries, SyncCursors, CacheEntries])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  static const _maxAttempts = 10;

  /// Coalescing enqueue. Replaces any pending write for the same entity.
  ///
  /// Without this, an offline session produces a queue proportional to the
  /// number of taps rather than the number of changes. Replaying it wastes
  /// battery, invites a 429, and can apply states the user already undid.
  Future<void> enqueue(OutboxEntriesCompanion entry) =>
      into(outboxEntries).insertOnConflictUpdate(entry);

  Future<List<OutboxEntry>> pending({int limit = 200}) {
    final now = DateTime.now();
    return (select(outboxEntries)
          ..where(
            (t) =>
                t.deferUntil.isNull() |
                t.deferUntil.isSmallerThanValue(now),
          )
          ..where((t) => t.attempts.isSmallerThanValue(_maxAttempts))
          // FIFO, strictly. Causal order matters: a delete that overtakes
          // its own create resurrects the row on the next pull.
          ..orderBy([(t) => OrderingTerm.asc(t.queuedAt)])
          ..limit(limit))
        .get();
  }

  Stream<int> watchPendingCount() {
    final count = outboxEntries.id.count();
    return (selectOnly(outboxEntries)..addColumns([count]))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Future<void> deleteEntry(String id) =>
      (delete(outboxEntries)..where((t) => t.id.equals(id))).go();

  Future<void> defer(String id, {required DateTime until}) =>
      (update(outboxEntries)..where((t) => t.id.equals(id))).write(
        OutboxEntriesCompanion(deferUntil: Value(until)),
      );

  Future<void> markFailed(String id, String reason) async {
    final row = await (select(outboxEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;

    await (update(outboxEntries)..where((t) => t.id.equals(id))).write(
      OutboxEntriesCompanion(
        attempts: Value(row.attempts + 1),
        lastError: Value(reason),
      ),
    );
  }

  Future<SyncCursor?> cursor(String entity) =>
      (select(syncCursors)..where((t) => t.entity.equals(entity)))
          .getSingleOrNull();

  Future<void> setCursor(String entity, DateTime serverTime) =>
      into(syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          entity: entity,
          serverTime: Value(serverTime),
          lastPulledAt: Value(DateTime.now()),
        ),
      );
}
