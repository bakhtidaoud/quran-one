import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/home/domain/feed_item.dart';
import 'package:quran_one/shared/design_system/q_home_card.dart';

/// Layer 2: domain-aware, no Riverpod.
///
/// The tafsir is a QDisclosure collapsed by default. A card that opens
/// at four hundred words is a card nobody finishes, but a card that
/// hides the tafsir entirely means the pairing is wasted.
class QVerseCard extends StatelessWidget {
  const QVerseCard({
    required this.item,
    this.onTap,
    super.key,
  });

  final VerseOfDay item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reading = context.reading;
    final text = context.text;
    final colors = context.colors;

    return QHomeCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QCardHeader(
            eyebrow: 'Verse of the day',
            title: 'Surah ${item.ref.surah}:${item.ref.number}',
            trailing: Icon(Icons.open_in_new,
                size: 16, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // The Arabic sits under its own RepaintBoundary. Uthmani
          // text with height 2.0 costs real layout time, and a
          // countdown tick must not pay for it sixty times a minute.
          RepaintBoundary(
            child: Text(
              item.arabic,
              textAlign: TextAlign.end,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: reading.mushaf.fontFamily,
                fontSize: reading.mushaf.fontSize,
                height: 2.0,
                color: reading.ink,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.provenance.reference,
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          // Provenance on the card, never behind a tap.
          const SizedBox(height: 4),
          Text(
            item.provenance.sourceName,
            style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (item.tafsir != null)
            QDisclosure(
              label: 'Tafsir by ${item.tafsir!.author}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.tafsir!.body, style: text.bodyMedium),
                  if (item.tafsir!.isAbridged)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 6),
                      child: Text(
                        'Abridged. Read the full commentary.',
                        style: text.labelSmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
