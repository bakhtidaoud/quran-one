import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// Composes scripture with the user's active translations.
///
/// This earns its existence as a use case because it orchestrates two
/// repositories and encodes a policy. A single pass-through call would not;
/// the controller would talk to the repository directly.
class GetAnnotatedRange {
  const GetAnnotatedRange(this._ayahs, this._translations);

  final AyahRepository _ayahs;
  final TranslationRepository _translations;

  Future<Result<List<AnnotatedAyah>, QFailure>> call(AyahRange range) async {
    final ayahResult = await _ayahs.getRange(range);
    if (ayahResult case Err(:final error)) return Err(error);

    final ayahs = (ayahResult as Ok<List<Ayah>, QFailure>).value;

    final packsResult = await _translations.installedPackIds();
    final packs = packsResult.valueOrNull ?? const <String>[];

    // No translation packs installed is a normal state, not a failure.
    // The Arabic still renders, which is the part that matters.
    if (packs.isEmpty) {
      return Ok([for (final a in ayahs) AnnotatedAyah(ayah: a)]);
    }

    final textResult = await _translations.getForRange(range, packs);
    final texts = textResult.valueOrNull ?? const <String, String>{};

    return Ok([
      for (final a in ayahs)
        AnnotatedAyah(
          ayah: a,
          translations: {
            for (final p in packs)
              if (texts['$p:${a.ref}'] != null) p: texts['$p:${a.ref}']!,
          },
        ),
    ]);
  }
}
