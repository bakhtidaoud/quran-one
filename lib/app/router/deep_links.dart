import 'package:quran_one/app/router/routes.dart';

/// Accepts the ayah references people actually paste.
///
/// `2:255`, `2/255`, `quran.com/2/255`, `quranone.app/read/surah/2?ayah=255`
/// and the share links every competitor emits. Refusing a link because it
/// came from a rival app punishes the user for our marketing problem.
class DeepLinkParser {
  const DeepLinkParser();

  static final _reference = RegExp(r'(\d{1,3})[:/-](\d{1,3})');
  static const _ayahCounts = 6236;

  /// Returns an in-app location, or null when the link is not a reference.
  String? toLocation(Uri uri) {
    final subject = uri.path.isEmpty ? uri.toString() : uri.path;

    // An explicit page link is unambiguous, so it wins over the loose
    // reference match below.
    final page = int.tryParse(uri.queryParameters['page'] ?? '');
    if (page != null && page >= 1 && page <= 604) {
      return '${Routes.read}/page/$page';
    }

    final match = _reference.firstMatch(subject);
    if (match == null) return null;

    final surah = int.parse(match.group(1)!);
    final ayah = int.parse(match.group(2)!);

    if (surah < 1 || surah > 114) return null;
    if (ayah < 1 || ayah > _ayahCounts) return null;

    return '${Routes.read}/surah/$surah?ayah=$ayah';
  }
}
