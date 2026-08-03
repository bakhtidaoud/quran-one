import 'package:quran_one/core/database/daos/outbox_dao.dart';
import 'package:quran_one/shared/domain/services/location_service.dart';

class SyncReport {
  const SyncReport({this.pushed = 0, this.pulled = 0, this.skipped = false});
  const SyncReport.skipped() : this(skipped: true);

  final int pushed;
  final int pulled;
  final bool skipped;
}

/// Push, then pull. Always that order.
///
/// Pulling first means the server's older copy of a row overwrites a local
/// edit that has not been sent yet, and the user watches their work vanish
/// with no error and no way to recover it.
class SyncEngine {
  const SyncEngine({
    required OutboxDao outbox,
    required ConnectivityService connectivity,
  })  : _outbox = outbox,
        _connectivity = connectivity;

  final OutboxDao _outbox;
  final ConnectivityService _connectivity;

  static const _cursorKey = 'all';

  Future<SyncReport> run({
    required Future<void> Function() drain,
    required Future<RemotePull> Function(DateTime? since) pull,
    required Future<void> Function(RemoteChange change) apply,
  }) async {
    if (!await _connectivity.isOnline) return const SyncReport.skipped();

    // 1. Local truth reaches the server.
    await drain();

    // 2. Only then do we accept the server's view.
    final cursor = await _outbox.cursor(_cursorKey);
    final remote = await pull(cursor?.serverTime);

    for (final change in remote.changes) {
      await apply(change);
    }

    await _outbox.setCursor(_cursorKey, remote.serverTime);

    return SyncReport(
      pushed: remote.accepted,
      pulled: remote.changes.length,
    );
  }
}

class RemotePull {
  const RemotePull({
    required this.changes,
    required this.serverTime,
    this.accepted = 0,
    this.hasMore = false,
  });

  final List<RemoteChange> changes;
  final DateTime serverTime;
  final int accepted;
  final bool hasMore;
}

class RemoteChange {
  const RemoteChange({
    required this.entity,
    required this.id,
    required this.payload,
    required this.deleted,
  });

  final String entity;
  final String id;
  final Map<String, dynamic> payload;

  /// Tombstone, never an absent row. A row that vanishes is
  /// indistinguishable from a row that never synced, and the difference is
  /// somebody's lost notes.
  final bool deleted;
}
