import 'package:flutter/foundation.dart';

/// Everything the ranker is allowed to see.
///
/// This is the boundary. The ranker is a pure function of this struct.
/// Nothing that is not in this struct enters the ranking decision.
///
/// Eight inputs were requested. Four of them were refused.
///
/// ACCEPTED:
///   language       locale-sensitive formatting only, never section gating
///   country        regional defaults (calculation method, school); not gating
///   learning goals drives ReviewDue and Wird rank; explicit, not inferred
///   premium status one gating decision: skip the paywall row
///
/// REFUSED, with reasons below:
///   prayer habits     see kBehaviouralInferenceIsNotSupported
///   reading history   see kBehaviouralInferenceIsNotSupported
///   favourite surahs  see kBehaviouralInferenceIsNotSupported
///   bookmarks         see kBehaviouralInferenceIsNotSupported
///
/// The single use of premium status in the ranker: the Premium row is
/// never shown to a subscriber. That is a suppression, not an
/// adaptation, and it is the only commerce-aware decision on Home.
@immutable
class HomeContext {
  const HomeContext({
    required this.locale,
    required this.countryCode,
    required this.hasPremium,
    required this.hasActiveGoal,
    required this.hasWird,
    required this.dueCardCount,
    required this.hasReadBefore,
    required this.achievementEarnedToday,
  });

  final String locale;
  final String countryCode;
  final bool hasPremium;

  /// A khatmah, a daily page goal, or any other explicit plan.
  /// Never inferred from reading frequency.
  final bool hasActiveGoal;

  final bool hasWird;
  final int dueCardCount;
  final bool hasReadBefore;
  final String? achievementEarnedToday;
}

/// The line this product does not cross.
///
/// Adapting Home based on prayer habits, reading history, favourite
/// surahs, or bookmarks means building a profile of religious practice.
/// Under GDPR that is Article 9 special-category data. The standing
/// promise is that reading history never reaches the server, and a
/// home-screen personalisation engine is the most likely component to
/// quietly break that promise, not maliciously, but because someone
/// will propose one more signal and it will seem harmless each time.
///
/// On-device inference is not a safe alternative. The moment a
/// relevance score exists on device, sending it is a one-line change
/// in a future sprint by someone who never read this file.
///
/// If the business later decides to build behavioural personalisation,
/// the decision must be deliberate, documented, and accompanied by
/// a DPIA, not inherited from a comment nobody removed.
const kBehaviouralInferenceIsNotSupported = true;
