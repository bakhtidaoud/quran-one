import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// One verse, as stored in the content pack.
///
/// Immutable and never edited. Scripture is not user data (P2).
class Ayah {
  const Ayah({
    required this.ref,
    required this.arabic,
    required this.juz,
    required this.page,
    this.sajdah = false,
  });

  final AyahRef ref;

  /// Uthmani script, exactly as verified. Never normalised, never trimmed.
  final String arabic;

  final int juz;
  final int page;
  final bool sajdah;

  /// The reader shows a sajdah marker and, if the user enables it, prompts
  /// after recitation. Getting this wrong has religious consequences, which
  /// is why it is a field on the entity and not a lookup table in the UI.
  bool get requiresSajdah => sajdah;
}

/// A surah index entry. Cheap enough to keep all 114 in memory.
class Surah {
  const Surah({
    required this.number,
    required this.arabicName,
    required this.latinName,
    required this.englishName,
    required this.ayahCount,
    required this.revelation,
    required this.startPage,
  });

  final int number;
  final String arabicName;
  final String latinName;
  final String englishName;
  final int ayahCount;
  final RevelationPlace revelation;
  final int startPage;
}

enum RevelationPlace { meccan, medinan }

/// An ayah plus whatever the user has chosen to see alongside it.
class AnnotatedAyah {
  const AnnotatedAyah({
    required this.ayah,
    this.translations = const {},
    this.transliteration,
    this.isBookmarked = false,
  });

  final Ayah ayah;

  /// Keyed by translation pack id, because users routinely read two.
  final Map<String, String> translations;

  final String? transliteration;
  final bool isBookmarked;
}
