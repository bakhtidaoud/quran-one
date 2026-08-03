import 'package:flutter/material.dart';
import 'package:quran_one/app/router/routes.dart';

/// A quick action is episodic, urgent, and unreachable in one tap by
/// any other route.
///
/// Failing any of those three tests, it is navigation and belongs in
/// the shell, or it is a setting and belongs in Settings. Applying the
/// test to the ten originally proposed leaves four.
///
/// Excluded, and why:
///
///   Read Quran    already bottom nav tab 2
///   Prayer Times  already bottom nav tab 3
///   Search        a persistent app bar affordance, not an action;
///                 putting it in a row of six makes it harder to reach
///   Bookmarks     a deliberate destination on the Read landing
///   Downloads     Settings, opened a handful of times ever
///   AI Assistant  see note at the bottom of this file
enum QuickAction {
  qibla(Icons.explore_outlined, Routes.qibla),
  tasbih(Icons.circle_outlined, Routes.tasbih),
  azkar(Icons.wb_twilight_outlined, Routes.azkar),
  hadith(Icons.menu_book_outlined, Routes.hadith);

  const QuickAction(this.icon, this.route);

  final IconData icon;
  final String route;

  /// Labels come from the localisation catalogue and must stay to a
  /// single word in every locale. If a locale cannot express one in a
  /// word the row wraps, and a wrapped row is a menu.
  String labelKey() => 'quickAction_$name';
}

/// The default set, in a frozen order.
///
/// The order never changes. Promoting azkar to first during its window
/// would be contextually clever and would destroy the muscle memory
/// that makes a four item row worth having at all. Context is
/// expressed as a dot instead.
const kDefaultQuickActions = <QuickAction>[
  QuickAction.qibla,
  QuickAction.tasbih,
  QuickAction.azkar,
  QuickAction.hadith,
];

/// Azkar is the only action with a time bound state.
///
/// Morning runs from Fajr for three hours; evening from an hour before
/// Maghrib until two hours after. Both boundaries are invented and are
/// madhhab sensitive: they need review by someone qualified.
///
/// The result drives a dot, never a badge count. A count implies a
/// quota, which is the wrong frame for remembrance.
bool isAzkarDue({
  required DateTime now,
  required DateTime fajr,
  required DateTime maghrib,
  required bool morningDone,
  required bool eveningDone,
}) {
  final inMorning = !now.isBefore(fajr) &&
      now.isBefore(fajr.add(const Duration(hours: 3)));
  if (inMorning) return !morningDone;

  final eveningOpens = maghrib.subtract(const Duration(hours: 1));
  final inEvening = !now.isBefore(eveningOpens) &&
      now.isBefore(maghrib.add(const Duration(hours: 2)));
  if (inEvening) return !eveningDone;

  // Outside both windows there is nothing outstanding. A dot still
  // showing at midnight is a reproach, and this app does not reproach
  // anyone.
  return false;
}

/// On the AI assistant, which was requested as a quick action.
///
/// Giving it equal visual weight to azkar puts a probabilistic text
/// generator at the same rank as remembrance of God. That is a
/// category error before it is a design one, and it is also the
/// highest risk surface in the product: risk AR-7, hallucinated hadith
/// stated with confidence.
///
/// It belongs behind the search field, as a secondary affordance where
/// the user has already framed their intent as a question and where an
/// answer arriving with citations reads as a search result rather than
/// as an oracle. That also keeps it off the worship paths entirely,
/// per principle P4.
