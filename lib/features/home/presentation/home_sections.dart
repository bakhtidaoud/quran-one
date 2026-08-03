import 'package:flutter/foundation.dart';
import 'package:quran_one/features/home/presentation/controllers/countdown.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// Home is a queue, not a grid.
///
/// The screen is assembled by evaluating a fixed sequence of rules and
/// emitting only the sections that have something to say. A row that
/// reports the absence of work ("no cards due today") is pixels spent
/// on nothing, and it is the single reason most dashboards feel busy.
///
/// Tier 1 sections are unconditional and never reorder. Tier 2 sections
/// are conditional but still fixed in relative order: the user must be
/// able to build muscle memory, so a section may appear or disappear
/// but must never overtake another.
sealed class HomeSection {
  const HomeSection();

  /// Lower sorts first. Values are spaced so a future section can be
  /// inserted without renumbering.
  int get rank;

  /// Tier 1 sections render even while their data is loading, because
  /// their position is part of the layout contract.
  bool get isTierOne => rank < 200;
}

// --- Tier 1: always present, fixed position --------------------------

class HijriHeader extends HomeSection {
  const HijriHeader({required this.hijri, required this.gregorian});

  /// Primary. Every competitor inverts this pair. The Gregorian date is
  /// already in the status bar four millimetres above; the Hijri date
  /// is the one nobody can recall.
  final String hijri;
  final String gregorian;

  @override
  int get rank => 100;
}

class PrayerSection extends HomeSection {
  const PrayerSection(this.countdown);

  final Countdown countdown;

  @override
  int get rank => 110;
}

class ContinueReadingSection extends HomeSection {
  const ContinueReadingSection({
    required this.ref,
    required this.isFirstTime,
  });

  final AyahRef ref;
  final bool isFirstTime;

  @override
  int get rank => 120;
}

// --- Tier 2: must earn its row ---------------------------------------

class ReviewDueSection extends HomeSection {
  const ReviewDueSection(this.dueCount) : assert(dueCount > 0);

  final int dueCount;

  @override
  int get rank => 200;
}

class WirdSection extends HomeSection {
  const WirdSection({required this.done, required this.target})
      : assert(done < target, 'a completed wird is not a task');

  final int done;
  final int target;

  @override
  int get rank => 210;
}

/// Shown once, on the day it is earned, and dismissible.
///
/// A permanent trophy shelf turns worship into a scoreboard. That is
/// the failure mode this section is deliberately shaped to avoid.
class AchievementSection extends HomeSection {
  const AchievementSection({required this.id, required this.title});

  final String id;
  final String title;

  @override
  int get rank => 220;
}

// --- Tier 3: below the fold, static order ----------------------------

class HadithSection extends HomeSection {
  const HadithSection();
  @override
  int get rank => 300;
}

class DuaSection extends HomeSection {
  const DuaSection();
  @override
  int get rank => 310;
}

/// Inputs to the queue. Deliberately a plain value type so the ordering
/// rules can be tested without a container.
@immutable
class HomeInputs {
  const HomeInputs({
    required this.hijri,
    required this.gregorian,
    required this.countdown,
    required this.resumeAt,
    this.hasReadBefore = false,
    this.dueCards = 0,
    this.wirdDone = 0,
    this.wirdTarget = 0,
    this.achievementEarnedToday,
    this.achievementTitle,
    this.dismissedAchievementIds = const <String>{},
  });

  final String hijri;
  final String gregorian;
  final Countdown countdown;
  final AyahRef resumeAt;
  final bool hasReadBefore;
  final int dueCards;
  final int wirdDone;
  final int wirdTarget;
  final String? achievementEarnedToday;
  final String? achievementTitle;
  final Set<String> dismissedAchievementIds;

  bool get hasWird => wirdTarget > 0;
}

/// Builds the ordered queue. This function is the information
/// architecture; everything else is rendering.
List<HomeSection> buildHomeSections(HomeInputs inputs) {
  final sections = <HomeSection>[
    HijriHeader(hijri: inputs.hijri, gregorian: inputs.gregorian),
    PrayerSection(inputs.countdown),
    ContinueReadingSection(
      ref: inputs.resumeAt,
      isFirstTime: !inputs.hasReadBefore,
    ),
  ];

  if (inputs.dueCards > 0) {
    sections.add(ReviewDueSection(inputs.dueCards));
  }

  if (inputs.hasWird && inputs.wirdDone < inputs.wirdTarget) {
    sections.add(
      WirdSection(done: inputs.wirdDone, target: inputs.wirdTarget),
    );
  }

  final achievement = inputs.achievementEarnedToday;
  if (achievement != null &&
      !inputs.dismissedAchievementIds.contains(achievement)) {
    sections.add(
      AchievementSection(id: achievement, title: inputs.achievementTitle!),
    );
  }

  sections
    ..add(const HadithSection())
    ..add(const DuaSection());

  // Sorting rather than trusting insertion order: adding a section in
  // the wrong place then becomes a rank mistake, which a test catches,
  // rather than a layout mistake, which nobody notices.
  sections.sort((a, b) => a.rank.compareTo(b.rank));
  return List.unmodifiable(sections);
}

/// Deliberately absent from this file, and from Home entirely:
///
/// - Weather. Costs a location prompt, a third party API and a network
///   dependency on the one screen that must render offline, and answers
///   no religious question.
/// - Bookmarks and favourites. Destinations you navigate to on purpose;
///   on Home they are links that push the prayer card down.
/// - Recent activity. A feed of your own past actions.
/// - Islamic calendar. Lives beside prayer times, where it is useful.
/// - Premium banner. Principle P4: worship paths never carry commerce,
///   and Home is the most visited worship surface in the app. Premium
///   is in Settings and appears at the point of need.
