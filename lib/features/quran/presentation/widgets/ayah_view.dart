import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';

/// One ayah: Arabic, then any active translations.
///
/// The screen reader announces the reference and the first clause, and
/// offers "Play recitation" as a custom action. It never reads the Arabic
/// aloud with TTS - synthetic recitation of the Quran is not acceptable.
class AyahView extends StatelessWidget {
  const AyahView({required this.annotated, super.key});

  final AnnotatedAyah annotated;

  @override
  Widget build(BuildContext context) {
    final reading = context.reading;
    final ayah = annotated.ayah;

    return Semantics(
      label: 'Ayah ${ayah.ref.number}',
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Play recitation'): () {},
        const CustomSemanticsAction(label: 'Bookmark'): () {},
        const CustomSemanticsAction(label: 'Copy'): () {},
        const CustomSemanticsAction(label: 'Share'): () {},
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arabic is always laid out RTL regardless of the UI locale.
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: ayah.arabic, style: reading.mushaf),
                    const TextSpan(text: ' '),
                    TextSpan(
                      // U+06DD, the end-of-ayah marker.
                      text: '\u06DD${ayah.ref.number}',
                      style: reading.verseNumber,
                    ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            if (ayah.requiresSajdah) ...[
              const SizedBox(height: 8),
              Text('Sajdah', style: reading.footnote),
            ],
            for (final entry in annotated.translations.entries) ...[
              const SizedBox(height: 12),
              Text(entry.value, style: reading.translation),
            ],
          ],
        ),
      ),
    );
  }
}
