import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';

/// Reads scripture from the installed content pack.
///
/// The surah index ships in the bundle because it is 114 rows and every
/// screen needs it. The ayah text does not: it is a signed, versioned
/// content pack so that a correction can ship without an app release.
class AyahLocalSource {
  AyahLocalSource();

  List<Surah>? _indexCache;

  Future<List<Surah>> surahIndex() async {
    if (_indexCache != null) return _indexCache!;

    final raw = await rootBundle.loadString('assets/data/surah_index.json');
    final list = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    return _indexCache = [
      for (final m in list)
        Surah(
          number: m['number'] as int,
          arabicName: m['arabic_name'] as String,
          latinName: m['latin_name'] as String,
          englishName: m['english_name'] as String,
          ayahCount: m['ayah_count'] as int,
          revelation: m['revelation'] == 'meccan'
              ? RevelationPlace.meccan
              : RevelationPlace.medinan,
          startPage: m['start_page'] as int,
        ),
    ];
  }

  /// Returns an empty list when the content pack is absent. The repository
  /// turns that into ContentPackMissingFailure - a downloadable state, not
  /// an error state.
  Future<List<Ayah>> getRange(int startSurah, int startAyah, int endSurah,
      int endAyah) async {
    // Wired to the Drift content-pack tables once the pack format lands.
    return const [];
  }
}
