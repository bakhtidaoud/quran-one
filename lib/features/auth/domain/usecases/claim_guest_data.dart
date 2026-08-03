import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';

/// Uploads local-only data on first sign-in, before the first pull.
///
/// Without this, a user with three months of memorisation who finally
/// creates an account watches an empty server state sync down over their
/// work. That is the single most destructive bug this app could ship, so
/// the claim is enqueued durably in the outbox and ordering is enforced:
/// claim, then pull, never the reverse.
class ClaimGuestData {
  const ClaimGuestData({
    required Future<List<PendingClaim>> Function() readOrphans,
    required Future<void> Function(PendingClaim) enqueue,
    required Future<void> Function(List<PendingClaim>) markClaimed,
  })  : _readOrphans = readOrphans,
        _enqueue = enqueue,
        _markClaimed = markClaimed;

  final Future<List<PendingClaim>> Function() _readOrphans;
  final Future<void> Function(PendingClaim) _enqueue;
  final Future<void> Function(List<PendingClaim>) _markClaimed;

  Future<Result<int, QFailure>> call() async {
    final orphans = await _readOrphans();
    if (orphans.isEmpty) return const Ok(0);

    for (final orphan in orphans) {
      await _enqueue(orphan);
    }

    // Only after every row is durably queued. A crash between these two
    // lines replays the enqueue, which the outbox coalesces by entity, so
    // the operation is safely idempotent.
    await _markClaimed(orphans);

    return Ok(orphans.length);
  }
}

class PendingClaim {
  const PendingClaim({
    required this.entity,
    required this.entityId,
    required this.payload,
  });

  final String entity;
  final String entityId;
  final Map<String, dynamic> payload;
}
