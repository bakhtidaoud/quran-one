// Merge rule tests.
//
// Every defect these catch is silent data loss rather than a visible
// error, which is why they are the highest value tests in the suite.
// The seed is fixed: a property failure must reproduce exactly.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/core/sync/merge_rules.dart';
import 'package:quran_one/core/sync/sync_entity.dart';

void main() {
  group('furthest', () {
    test('never regresses a reading position', () {
      expect(MergeRules.furthest(local: 200, remote: 40), 200);
      expect(MergeRules.furthest(local: 40, remote: 200), 200);
    });

    test('the tablet case', () {
      // A tablet left open on an early page writes a newer timestamp
      // than the phone that actually did the reading. Last-write-wins
      // would return the early page and delete the session.
      const phonePage = 312;
      const staleTabletPage = 8;
      expect(MergeRules.furthest(local: staleTabletPage, remote: phonePage),
          phonePage);
    });
  });

  group('lastWrite', () {
    final older = DateTime.utc(2026, 8, 3, 10);
    final newer = DateTime.utc(2026, 8, 3, 11);

    test('picks the newer client timestamp', () {
      expect(
        MergeRules.lastWrite<String>(
          local: 'a',
          localAt: older,
          remote: 'b',
          remoteAt: newer,
        ),
        'b',
      );
    });

    test('a tie resolves to the incoming value', () {
      // Deterministic tie breaking matters more than which side wins:
      // two devices must converge on the same answer without a round
      // trip. Preferring the incoming value makes the server the
      // arbiter of ties.
      expect(
        MergeRules.lastWrite<String>(
          local: 'a',
          localAt: older,
          remote: 'b',
          remoteAt: older,
        ),
        'b',
      );
    });
  });

  group('hifz cards', () {
    test('more repetitions wins regardless of timestamp', () {
      // Repetition count is monotonic and irreplaceable. A timestamp is
      // not: a device with a wrong clock can otherwise erase months of
      // memorisation history. This is risk AR-3.
      expect(
        MergeRules.incomingWins(
          localRepetitions: 41,
          localAt: DateTime.utc(2026, 8, 3, 12),
          remoteRepetitions: 12,
          remoteAt: DateTime.utc(2026, 8, 3, 13),
        ),
        isFalse,
      );
    });

    test('ties fall back to the timestamp', () {
      expect(
        MergeRules.incomingWins(
          localRepetitions: 12,
          localAt: DateTime.utc(2026, 8, 3, 12),
          remoteRepetitions: 12,
          remoteAt: DateTime.utc(2026, 8, 3, 13),
        ),
        isTrue,
      );
    });
  });

  group('properties over 1000 random pairs', () {
    test('merge is commutative and idempotent', () {
      final random = Random(20260803);

      for (var i = 0; i < 1000; i++) {
        final a = _Card.random(random);
        final b = _Card.random(random);

        final ab = _merge(a, b);
        final ba = _merge(b, a);

        expect(
          ab.repetitions,
          ba.repetitions,
          reason: 'merge order changed the outcome for $a and $b',
        );

        // A push that succeeded server side but lost its response is
        // retried. Without idempotence that retry is data loss.
        expect(_merge(ab, b).repetitions, ab.repetitions);
        expect(_merge(ab, a).repetitions, ab.repetitions);
      }
    });
  });

  group('divergence detection', () {
    test('identical revisions are not divergent', () {
      expect(MergeRules.isDivergent(localRevision: 7, remoteRevision: 7),
          isFalse);
    });

    test('a lower remote revision is divergent', () {
      expect(MergeRules.isDivergent(localRevision: 7, remoteRevision: 5),
          isTrue);
    });
  });

  group('rule registry', () {
    test('every entity has a rule', () {
      for (final entity in SyncEntity.values) {
        expect(() => MergeRules.ruleFor(entity), returnsNormally,
            reason: '${entity.name} has no merge rule');
      }
    });

    test('reading position uses furthest, not last write', () {
      expect(MergeRules.ruleFor(SyncEntity.readingPosition),
          MergeRule.furthest);
    });

    test('entitlement is server authoritative', () {
      // Principle P6: the client is authoritative for worship, the
      // server for money. A client that can win an entitlement merge
      // is a client that can grant itself premium.
      expect(MergeRules.ruleFor(SyncEntity.entitlement), MergeRule.serverWins);
    });
  });
}

class _Card {
  const _Card(this.repetitions, this.updatedAt);

  factory _Card.random(Random random) => _Card(
        random.nextInt(60),
        DateTime.utc(2026, 8, 3).add(Duration(minutes: random.nextInt(4320))),
      );

  final int repetitions;
  final DateTime updatedAt;

  @override
  String toString() => 'Card(reps: $repetitions, at: $updatedAt)';
}

_Card _merge(_Card local, _Card remote) {
  final takeRemote = MergeRules.incomingWins(
    localRepetitions: local.repetitions,
    localAt: local.updatedAt,
    remoteRepetitions: remote.repetitions,
    remoteAt: remote.updatedAt,
  );
  return takeRemote ? remote : local;
}
