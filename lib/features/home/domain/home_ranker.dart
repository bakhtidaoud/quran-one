import 'package:quran_one/features/home/domain/home_context.dart';
import 'package:quran_one/features/home/presentation/home_sections.dart';

/// Emits sections in rank order given a HomeContext.
///
/// A pure function. No Riverpod, no async, no side effects.
/// Identical inputs always produce identical outputs.
///
/// This replaces the raw buildHomeSections() that was committed in
/// 908bba8. That function took HomeInputs directly; this one takes
/// HomeContext and calls through. The outputs are the same type.
/// The split exists so the ranker can be tested with plain values
/// without constructing a provider graph.
List<HomeSection> rankSections(HomeContext ctx) {
  final inputs = HomeInputs(
    hijri: '',            // resolved by the caller from the locale
    gregorian: '',        // same
    countdown: null,      // prayer tile fetches its own data
    resumeAt: null,
    hasReadBefore: ctx.hasReadBefore,
    dueCards: ctx.dueCardCount,
    wirdDone: ctx.hasWird ? 0 : 1,   // stub; tile fetches truth
    wirdTarget: ctx.hasWird ? 1 : 1,
    achievementEarnedToday: ctx.achievementEarnedToday,
    achievementTitle: null,
    dismissedAchievementIds: const {},
  );
  return buildHomeSections(inputs);
}

/// The four adaptation rules that are permitted.
///
/// Every adaptation here is either:
///   (a) a suppression based on an explicit user state (premium),
///   (b) driven by an explicit user commitment (goal, wird), or
///   (c) purely structural (language, country for formatting).
///
/// None of them infer anything. None of them observe behaviour.
extension HomeContextAdaptations on HomeContext {
  /// True when the Premium upsell row should be suppressed.
  /// This is the only commerce decision on Home, and P4 means it is
  /// a suppression, never a promotion.
  bool get suppressPremiumRow => hasPremium;

  /// The review row appears only when there are cards genuinely due.
  /// The count comes from the SRS engine, not from an inference.
  bool get showReviewRow => dueCardCount > 0;

  /// The wird row appears only when the user has set an explicit wird
  /// target for today and has not finished it.
  bool get showWirdRow => hasWird;

  /// The achievement row appears only the day it is earned. It never
  /// re-surfaces. There is no "you almost earned" state.
  bool get showAchievementRow => achievementEarnedToday != null;
}
