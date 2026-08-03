import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';

/// Layer 1 card shell. Domain-blind: takes a child, returns a shaped
/// surface. It has no title parameter, because the moment it has one
/// it also needs a subtitle, an icon, a trailing widget, and a flag
/// for whether the title is centred.
///
/// To add a header, compose QCardHeader inside the child.
class QHomeCard extends StatelessWidget {
  const QHomeCard({
    required this.child,
    this.color,
    this.onTap,
    this.padding,
    super.key,
  });

  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color ?? context.colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ??
              const EdgeInsetsDirectional.symmetric(
                  horizontal: 16, vertical: 14),
          child: child,
        ),
      ),
    );
  }
}

/// Eyebrow label + title + optional trailing icon.
///
/// Reused by verse, hadith and any other card that follows the same
/// information hierarchy. Label and title are not parameters on
/// QHomeCard itself to keep the shell from accumulating optional fields.
class QCardHeader extends StatelessWidget {
  const QCardHeader({
    required this.title,
    this.eyebrow,
    this.trailing,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow!,
                  style: text.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              if (eyebrow != null) const SizedBox(height: 2),
              Text(title, style: text.titleSmall),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A collapsed body that expands on tap.
///
/// Used for tafsir under the verse card. Collapsed by default because
/// a card that opens at four hundred words is a card nobody finishes.
class QDisclosure extends StatefulWidget {
  const QDisclosure({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  State<QDisclosure> createState() => _QDisclosureState();
}

class _QDisclosureState extends State<QDisclosure>
    with SingleTickerProviderStateMixin {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 10),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: context.text.labelMedium
                      ?.copyWith(color: context.colors.primary),
                ),
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right, size: 18),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsetsDirectional.only(top: 8),
            child: widget.child,
          ),
          crossFadeState:
              _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

/// 30-day consistency strip. Dots, not flames.
///
/// A dot that is filled means read. A dot that is empty means not.
/// A count underneath says how many out of thirty. No counter that
/// resets, no streak, no reproach for a gap.
class QDotStrip extends StatelessWidget {
  const QDotStrip({
    required this.days,
    required this.count,
    super.key,
  });

  /// 30 booleans, oldest first.
  final List<bool> days;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = colors.primary;
    final empty = colors.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final read in days)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: read ? filled : empty,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$count of the last 30 days',
          style: context.text.labelSmall
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
