import 'package:flutter/foundation.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// The daily set. Not a feed.
///
/// A feed is infinite, algorithmic and optimised for time spent. None
/// of those three properties belong on religious content. What ships is
/// a finite, fixed, deterministic set of three items that is identical
/// for the whole day and identical on every device the user owns.
///
/// The set is exhausted by design. When the user reaches the end there
/// is nothing more, and the correct next action is to go and read.
sealed class FeedItem {
  const FeedItem({required this.id, required this.provenance});

  final String id;

  /// Every item carries its chain. Nothing renders without one.
  final Provenance provenance;

  /// Order within the day. Fixed, never personalised.
  int get rank;
}

/// The verse of the day, and the tafsir *of that verse*.
///
/// Tafsir is not an independent daily item. A random commentary on a
/// verse other than the one shown above it is incoherent, and pairing
/// them is the whole reason this is one card with a disclosure rather
/// than two cards.
class VerseOfDay extends FeedItem {
  const VerseOfDay({
    required super.id,
    required super.provenance,
    required this.ref,
    required this.arabic,
    required this.translationKey,
    this.tafsir,
  });

  final AyahRef ref;
  final String arabic;

  /// 'packId:surah:ayah'.
  final String translationKey;

  /// Collapsed by default. Tafsir is long, and a card that opens at
  /// four hundred words is a card nobody finishes.
  final TafsirExcerpt? tafsir;

  @override
  int get rank => 100;
}

class HadithOfDay extends FeedItem {
  const HadithOfDay({
    required super.id,
    required super.provenance,
    required this.arabic,
    required this.translation,
    required this.grading,
  });

  final String arabic;
  final String translation;

  /// Sahih or hasan only. Nothing weaker is in the pool, and nothing
  /// ungraded is in the pool at all. See risk AR-7.
  final HadithGrading grading;

  @override
  int get rank => 110;
}

/// The one item with any contextual selection, and it is contextual
/// rather than personalised: derived from the clock and the Hijri
/// calendar, not from anything the user has done.
class DuaOfDay extends FeedItem {
  const DuaOfDay({
    required super.id,
    required super.provenance,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.occasion,
  });

  final String arabic;
  final String transliteration;
  final String translation;
  final DuaOccasion occasion;

  @override
  int get rank => 120;
}

@immutable
class TafsirExcerpt {
  const TafsirExcerpt({
    required this.workId,
    required this.author,
    required this.body,
    required this.isAbridged,
  });

  final String workId;
  final String author;
  final String body;

  /// Always stated on screen when true, with a link to the full text.
  /// Silently abridging a scholar is a form of misquotation.
  final bool isAbridged;
}

@immutable
class Provenance {
  const Provenance({
    required this.sourceId,
    required this.sourceName,
    required this.reference,
    required this.packVersion,
    this.translator,
  });

  final String sourceId;

  /// Rendered on the card, never behind a tap. "Sahih al-Bukhari 6407"
  /// is part of the content, not metadata.
  final String sourceName;
  final String reference;

  /// Which content pack version produced this item. Makes the whole
  /// day reproducible and auditable after the fact.
  final String packVersion;

  final String? translator;
}

enum HadithGrading { sahih, hasan }

enum DuaOccasion {
  morning,
  evening,
  beforeSleep,
  afterPrayer,
  friday,
  rain,
  distress,
  ramadan,
  general,
}

/// Deliberately absent, and the most important refusal in this file:
///
/// There is no IslamicQuote type. Unattributed inspirational quotation
/// is the single largest vector for fabricated hadith on the internet.
/// A card that renders beautiful text with no chain, or with "Prophet
/// Muhammad (PBUH)" as the entire attribution, is a fabrication engine
/// with a nice font. If a statement is authentic it is a hadith and it
/// carries a grading; if it is from a scholar it carries a name and a
/// work; if it carries neither it does not ship.
///
/// Also absent: LearningTip, MemorizationReminder and PrayerReminder.
/// None of them are content. A memorisation reminder is the tier 2
/// review row on Home, driven by the actual due count. A prayer
/// reminder is a notification. A learning tip is a coaching message,
/// and mixing coaching into a surface that also renders revelation
/// flattens the two into the same register.
