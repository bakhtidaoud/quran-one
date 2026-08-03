import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Tier 2. Synced, account-owned, small.
///
/// Deliberately excludes bookmarks and learning progress. Those are
/// separate aggregates with their own merge rules; folding them in here
/// creates an object that must be refetched every time a bookmark
/// changes.
@immutable
class AccountProfile {
  const AccountProfile({
    required this.locale,
    required this.prayer,
    required this.notifications,
    this.displayName,
    this.avatar = const GeneratedAvatar(),
    this.translationPackIds = const [],
    this.reciterId,
    this.analyticsOptIn = false,
  });

  final Locale locale;
  final PrayerSettings prayer;
  final NotificationSettings notifications;
  final String? displayName;
  final Avatar avatar;
  final List<String> translationPackIds;
  final String? reciterId;

  /// Default false, always, on every code path.
  final bool analyticsOptIn;
}

sealed class Avatar {
  const Avatar();
}

/// The default, and for now the only option.
///
/// A deterministic geometric pattern derived from the account id. Three
/// reasons for refusing photo uploads: user-generated images demand a
/// moderation queue the team cannot staff, they add storage and CDN cost
/// for zero product value in an app nobody uses socially, and a
/// meaningful share of this audience deliberately avoids images of faces.
/// A pattern offends nobody.
class GeneratedAvatar extends Avatar {
  const GeneratedAvatar({this.seed});
  final String? seed;
}

class InitialAvatar extends Avatar {
  const InitialAvatar(this.initials);

  /// Never passed through toUpperCase(). In Turkish, i becomes a dotted
  /// capital and the user's own name comes back wrong.
  final String initials;
}

enum Prayer { fajr, dhuhr, asr, maghrib, isha }

/// Three states, not a boolean.
///
/// Silent is the setting most people actually want for Fajr. Collapsing
/// it into off means they lose the reminder entirely, which is the exact
/// prayer they most need reminding of.
enum AthanMode { off, silent, athan }

@immutable
class PrayerSettings {
  const PrayerSettings({
    this.calculationMethod = 'muslim_world_league',
    this.asrMethod = 'standard',
    this.highLatitudeRule = 'middle_of_night',
    this.manualAdjustments = const {},
  });

  final String calculationMethod;
  final String asrMethod;
  final String highLatitudeRule;

  /// Per-prayer offset in minutes, clamped to -30..30.
  ///
  /// Non-negotiable. Local mosques routinely differ from every calculated
  /// method, and an app that cannot be made to match the masjid down the
  /// road gets uninstalled no matter how good its astronomy is.
  final Map<Prayer, int> manualAdjustments;
}

@immutable
class NotificationSettings {
  const NotificationSettings({
    this.perPrayer = const {},
    this.dailyAyahMinuteOfDay,
  });

  final Map<Prayer, AthanMode> perPrayer;
  final int? dailyAyahMinuteOfDay;
}
