/// Home screen personalisation tiers.
///
/// Three tiers. The default is tier 0 and it is the whole product for
/// most users. Nothing in any tier leaves the device. Nothing in any
/// tier infers religious practice from behaviour.
///
/// This mirrors the daily-feed tiers in daily_selection.dart. They are
/// separate types because the home ranker and the feed selector have
/// different inputs and different use cases, even though they share
/// the same philosophy.
library;

/// Tier 0 (none): sections appear based on structural facts only.
///
/// Which sections fire:
///   HijriHeader      always
///   PrayerSection    always
///   ContinueReading  always (first-time variant if !hasReadBefore)
///   ReviewDue        only when dueCardCount > 0
///   Wird             only when an explicit wird target is set
///   Achievement      only the day it is earned
///   Hadith           always
///   Dua              always
///
/// No inference. No profile. Identical for two users with identical
/// explicit state.
const kTier0Description = '
  Structural facts only. No reading history, no prayer data,
  no behavioural inference. Safe for Article 9 without a DPIA.
';

/// Tier 1 (contextual): time, Hijri date, locale.
///
/// Additions over tier 0:
///   DuaSection       selects occasion from the clock (morning / evening /
///                    friday / ramadan) — this is a clock, not a profile
///   QuickActionBar   azkar dot reflects the prayer window
///
/// These are not user-specific. Two users in the same timezone at the
/// same time see the same contextual state. This cannot be switched off
/// because it is not profiling; it is formatting.
const kTier1Description = '
  Clock and calendar. Not user-specific. Cannot be opted out.
';

/// Tier 2 (declared): topics the user explicitly selected.
///
/// Additions over tier 1:
///   Feed channel     filtered to declared topics, with a hard floor
///                    of unfiltered items so the user encounters
///                    content they did not select
///
/// Stored locally. Never synced. Never sent to the server.
/// Opt-in from Settings. Revocable at any time.
///
/// The hard floor exists because a topic filter over scripture risks
/// a bubble: someone selecting only mercy-themed content and never
/// encountering anything else. The floor is a scholarly question;
/// this code only enforces that one must exist.
const kTier2Description = '
  Explicit user preference, on-device only, never synced,
  with a mandatory unfiltered floor.
';

/// There is no tier 3 and there will not be one.
///
/// Tier 3 would be behavioural inference: selecting or weighting
/// content based on what the user reads, how often they pray, which
/// verses they linger on, or what they bookmark.
///
/// See kBehaviouralInferenceIsNotSupported in home_context.dart.
/// The argument there is complete and is not repeated here.
const kTier3ExistsAndIsRefused = true;

/// Premium status interacts with personalisation in exactly one way.
///
/// Subscribing suppresses the Premium upsell row. That is all.
/// It does not unlock a "personalised feed", it does not change the
/// section order, and it does not grant access to behavioural
/// inference. Premium is a business layer and P4 keeps it off the
/// worship surface.
const kPremiumPersonalisationScope = '
  Premium status suppresses the upsell row only.
  It is not a personalisation tier.
';
