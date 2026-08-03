import 'package:flutter/foundation.dart';

/// What a merge will do, computed by the server before anything is
/// written.
///
/// Merging two real accounts is rare, destructive and irreversible, so it
/// is server-side, explicit, and confirmed against concrete numbers. The
/// client's only job is to show what will be lost.
@immutable
class MergePreview {
  const MergePreview({
    required this.bookmarksKept,
    required this.hifzCardsKept,
    required this.hifzCardsDiscarded,
    required this.subscriptionOutcome,
  });

  final int bookmarksKept;
  final int hifzCardsKept;

  /// A non-zero value here must be rendered as a literal count.
  ///
  /// "Some progress may be lost" is not consent. "You will lose 41 cards
  /// of review history" is.
  final int hifzCardsDiscarded;

  /// Plain language, resolved server-side, because the answer depends on
  /// store receipts the client cannot see.
  final String subscriptionOutcome;

  bool get isLossless => hifzCardsDiscarded == 0;
}

/// Field-level merge reuses the rules already implemented in
/// apps/sync/services.py, run once over two user ids rather than over one
/// user's two devices:
///
///   bookmark         -> last write by client_updated_at
///   reading position -> the FURTHEST, not the latest
///   hifz card        -> more repetitions wins, timestamp breaks ties
///
/// Merge must be commutative and idempotent, because a network failure
/// halfway through means the client retries. A property test over random
/// account pairs is the cheapest way to keep that true.
