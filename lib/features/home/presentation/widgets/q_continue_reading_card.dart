import 'package:flutter/material.dart';
import 'package:quran_one/core/i18n/numerals.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// The second highest value element on Home, and the one every
/// competitor renders as a progress bar.
///
/// A bar says "you are 34% through Al-Baqarah". The verse itself
/// re-enters you into the reading. That difference is the whole design
/// of this card.
class QContinueReadingCard extends StatelessWidget {
  const QContinueReadingCard({
    required this.ref,
    required this.surahName,
    required this.preview,
    required this.onTap,
    this.isFirstTime = false,
    super.key,
  });

  /// Where the reader will resume.
  final AyahRef ref;

  /// Localised surah name, already resolved by the caller.
  final String surahName;

  /// Uthmani text of the resume point, unmodified.
  final String preview;

  /// A fresh install has no reading position. Rather than an empty
  /// card, the card offers Al-Fatiha and changes its label.
  final bool isFirstTime;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reading = context.reading;
    final numerals = NumeralSystem.forLocale(Localizations.localeOf(context));

    return Semantics(
      button: true,
      label: isFirstTime
          ? 'Start reading, $surahName'
          : 'Continue reading, $surahName, verse '
              '${numerals.format(ref.number)}',
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: context.shape.card,
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: context.shape.card,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isFirstTime ? 'Start reading' : 'Continue',
                      style: context.text.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('\u00B7',
                        style: TextStyle(color: colors.outlineVariant)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isFirstTime
                            ? surahName
                            : '$surahName ${numerals.format(ref.number)}',
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Two lines maximum. This is a doorway, not a reader.
                // Scripture is rendered at the reading theme's ink
                // colour so it holds the AAA contrast floor even here.
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: reading.mushaf.copyWith(
                    color: reading.ink,
                    // Deliberately smaller than the reader's own size:
                    // the user's mushaf preference can reach 48, which
                    // would let this card swallow the screen.
                    fontSize: 22,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
