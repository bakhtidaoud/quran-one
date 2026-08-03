/// Every route path in the application, in one place.
///
/// String literals for navigation are banned by lint. A typo in a deep link
/// path should be a compile error, not a 404 in production.
abstract final class Routes {
  static const onboarding = '/onboarding';

  static const home = '/home';
  static const azkar = '/home/azkar';
  static const hadith = '/home/hadith';
  static const tasbih = '/home/tasbih';

  static const read = '/read';
  static const readSaved = '/read/saved';
  static String surah(int id) => '/read/surah/$id';
  static String juz(int id) => '/read/juz/$id';

  static const prayer = '/prayer';
  static const prayerCalendar = '/prayer/calendar';
  static const prayerAthan = '/prayer/athan';

  static const learn = '/learn';
  static const learnProgress = '/learn/progress';
  static String plan(String id) => '/learn/plan/$id';

  /// The reader is a root route, above the shell.
  ///
  /// Reading is the point of the product; it should not be framed by a
  /// navigation bar advertising four other places to be.
  static String reader(int surahId, {int? ayah, String? mode}) {
    final params = <String, String>{
      if (ayah != null) 'ayah': '$ayah',
      if (mode != null) 'mode': mode,
    };
    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    return '/reader/$surahId$query';
  }

  static const review = '/review';
  static const qibla = '/qibla';
  static const search = '/search';
  static const settings = '/settings';
  static const settingsAccessibility = '/settings/accessibility';
}
