import 'dart:async';

import 'package:quran_one/app/di.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/core/logging/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'outbox_controller.g.dart';

/// Drains the write queue when the network allows it.
///
/// The queue is the state. `state` here is only a count for the UI badge;
/// the durable truth is the OutboxEntries table, so a force-quit mid-sync
/// loses nothing and resumes on next launch.
@Riverpod(keepAlive: true)
class OutboxController extends _$OutboxController {
  static const _batchSize = 200;

  @override
  Stream<int> build() {
    final db = ref.watch(appDatabaseProvider);

    ref.listen(connectivityChangesProvider, (_, next) {
      if (next.valueOrNull ?? false) unawaited(drain());
    });

    // Drift's watch, not a poll. The count is genuinely reactive because
    // the table is the source of truth.
    return db.watchPendingOutboxCount();
  }

  Future<void> drain() async {
    final db = ref.read(appDatabaseProvider);
    final api = ref.read(syncApiProvider);

    for (final entry in await db.pendingOutbox(limit: _batchSize)) {
      final Result<void, QFailure> result = await api.push(entry.payload);

      switch (result) {
        case Ok():
          await db.deleteOutbox(entry.id);

        case Err(error: RateLimitedFailure(:final retryAfter)):
          // Stop the entire drain. Continuing to hammer a 429 is how an
          // app earns an IP ban for every user on the same carrier NAT.
          await db.deferOutbox(
            entry.id,
            until: DateTime.now().add(retryAfter),
          );
          return;

        case Err(error: NetworkFailure()):
        case Err(error: TimeoutFailure()):
          // Still offline. Leave the queue exactly as it is.
          return;

        case Err(:final error):
          // A 4xx will never succeed on retry. Park the row rather than
          // loop forever on a poisoned entry that blocks everything behind
          // it in the queue.
          QLog.instance.warn(
            'outbox entry parked',
            context: {'id': entry.id, 'reason': error.message},
          );
          await db.markOutboxFailed(entry.id);
      }
    }
  }
}
