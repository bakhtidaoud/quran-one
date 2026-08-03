import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/home/domain/feed_item.dart';
import 'package:quran_one/shared/design_system/q_home_card.dart';

/// Layer 2: domain-aware, no Riverpod.
class QHadithCard extends StatelessWidget {
  const QHadithCard({
    required this.item,
    this.onTap,
    super.key,
  });

  final HadithOfDay item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final reading = context.reading;

    return QHomeCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QCardHeader(
            eyebrow: 'Hadith of the day',
            title: item.provenance.sourceName,
            trailing: _GradingChip(grading: item.grading),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: Text(
              item.arabic,
              textAlign: TextAlign.end,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: reading.mushaf.fontFamily,
                fontSize: reading.mushaf.fontSize * 0.8,
                height: 1.9,
                color: reading.ink,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(item.translation, style: text.bodyMedium),
          const SizedBox(height: 6),
          // Grading is on the card. A hadith card without a visible
          // grading is a fabrication engine with a nice font.
          Text(
            item.provenance.reference,
            style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _GradingChip extends StatelessWidget {
  const _GradingChip({required this.grading});

  final HadithGrading grading;

  @override
  Widget build(BuildContext context) {
    final label = switch (grading) {
      HadithGrading.sahih => 'Sahih',
      HadithGrading.hasan => 'Hasan',
    };
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: context.text.labelSmall
            ?.copyWith(color: context.colors.onSecondaryContainer),
      ),
    );
  }
}
