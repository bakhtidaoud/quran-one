import 'package:quran_one/core/sync/sync_entity.dart';

/// Pure merge functions. No IO, no Drift, no Dio.
///
/// These must be commutative and idempotent, because a push that succeeds
/// on the server but loses its response is retried. merge(a, b) has to
/// equal merge(b, a), and merge(merge(a, b), b) has to equal merge(a, b).
/// A property test over a thousand random pairs is the cheapest way to
/// keep that true, and it is the test most worth writing in this file's
/// vicinity.
class MergeRules {
  const MergeRules._();

  /// Newest client_updated_at wins. Ties keep the local copy, because a
  /// no-op write is cheaper than a spurious sync round trip.
  static T lastWrite<T>({
    required T local,
    required T remote,
    required DateTime localAt,
    required DateTime remoteAt,
  }) =>
      remoteAt.isAfter(localAt) ? remote : local;

  /// Higher page number wins regardless of timestamp.
  static int furthest({required int local, required int remote}) =>
      local >= remote ? local : remote;

  /// More repetitions wins. Equal repetitions fall back to timestamp.
  ///
  /// Repetitions beat the clock because review history is cumulative and
  /// irrecoverable: a card reviewed forty times on one device and twice
  /// on another represents forty real reviews, and taking the newer row
  /// silently deletes thirty-eight of them.
  static bool incomingWins({
    required int localRepetitions,
    required int remoteRepetitions,
    required DateTime localAt,
    required DateTime remoteAt,
  }) {
    if (remoteRepetitions != localRepetitions) {
      return remoteRepetitions > localRepetitions;
    }
    return remoteAt.isAfter(localAt);
  }

  /// Returns true when both sides changed since the common ancestor, in
  /// which case the caller must persist a SyncConflict row rather than
  /// discarding either version.
  static bool isDivergent({
    required DateTime localAt,
    required DateTime remoteAt,
    required DateTime? ancestorAt,
  }) {
    if (ancestorAt == null) return false;
    return localAt.isAfter(ancestorAt) && remoteAt.isAfter(ancestorAt);
  }

  static MergeRule ruleFor(SyncEntity entity) => entity.merge;
}

/// Two invariants this file cannot enforce but that the engine must hold:
///
/// 1. PUSH BEFORE PULL, always. The reverse order means an offline edit
///    is overwritten by the server's older copy and then pushed back up
///    as though it were an edit. Users describe this as "the app undid my
///    work", and they are describing it accurately.
///
/// 2. The cursor advances ONLY after apply() commits, and it stores the
///    SERVER's clock. A device four minutes fast will otherwise skip
///    every change made in those four minutes, permanently, with no error
///    and a reproduction rate of exactly one device.
