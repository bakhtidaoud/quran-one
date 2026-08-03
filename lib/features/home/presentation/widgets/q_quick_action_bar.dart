import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/home/domain/quick_action.dart';
import 'package:quran_one/features/home/presentation/home_layout.dart';

/// A single row of four icon buttons directly beneath the app bar.
///
/// Not a two by three grid of coloured tiles: that is where a dashboard
/// becomes a launcher. Not an overflow menu either, which is what
/// docs/HOME_IA.md originally specified and which this widget
/// deliberately supersedes. An overflow hides all four behind a three
/// dot icon most users never press. That is acceptable for hadith and
/// wrong for azkar, which is time bound, and wrong for qibla, which is
/// wanted urgently in an unfamiliar room.
class QQuickActionBar extends StatelessWidget {
  const QQuickActionBar({
    required this.onSelected,
    this.actions = kDefaultQuickActions,
    this.dueActions = const <QuickAction>{},
    this.labelResolver,
    super.key,
  });

  final List<QuickAction> actions;
  final Set<QuickAction> dueActions;
  final ValueChanged<QuickAction> onSelected;

  /// Injected so this widget stays testable without a localisation
  /// delegate. Production passes the generated catalogue lookup.
  final String Function(QuickAction)? labelResolver;

  @override
  Widget build(BuildContext context) {
    final layout = HomeLayout.of(context);

    return Semantics(
      container: true,
      // Not a toolbar role. These are four unrelated destinations, not
      // a set of controls acting on shared content.
      explicitChildNodes: true,
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: _QuickActionButton(
                action: action,
                label: labelResolver?.call(action) ?? _fallback(action),
                isDue: dueActions.contains(action),
                showLabel: layout.showsQuickActionLabels,
                onTap: () => onSelected(action),
              ),
            ),
        ],
      ),
    );
  }

  static String _fallback(QuickAction action) =>
      action.name[0].toUpperCase() + action.name.substring(1);
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.label,
    required this.isDue,
    required this.showLabel,
    required this.onTap,
  });

  final QuickAction action;
  final String label;
  final bool isDue;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      // Spoken even when the label is not drawn. An icon only row is
      // not an excuse for an unlabelled control, and the due state is
      // in the label rather than only in a six pixel dot.
      label: isDue ? '$label, due now' : label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: ConstrainedBox(
          // 48dp floor with or without the label.
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconWithDot(
                  icon: action.icon,
                  isDue: isDue,
                  colour: colors.onSurfaceVariant,
                  dotColour: colors.primary,
                ),
                if (showLabel) ...[
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconWithDot extends StatelessWidget {
  const _IconWithDot({
    required this.icon,
    required this.isDue,
    required this.colour,
    required this.dotColour,
  });

  final IconData icon;
  final bool isDue;
  final Color colour;
  final Color dotColour;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24, color: colour),
        if (isDue)
          // Directional so the dot lands top left in Arabic without a
          // mirroring hack.
          PositionedDirectional(
            top: -1,
            end: -1,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColour,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

extension QuickActionLayout on HomeLayout {
  /// Labels are hidden only on the narrowest phones, where four
  /// labelled items force ellipsis, and an ellipsised label is worse
  /// than no label at all.
  ///
  /// At 200 percent text scale on a compact layout the row keeps its
  /// icons and drops labels rather than wrapping: a four item row that
  /// becomes four stacked rows has silently turned into a menu.
  bool get showsQuickActionLabels => this != HomeLayout.compact;

  /// In the expanded two column layout the row moves to the top of the
  /// second column, beside tier 1 rather than beneath it.
  ///
  /// It never becomes a NavigationRail. A rail implies these are
  /// primary destinations, which is exactly what they are not.
  bool get quickActionsInSecondColumn => isTwoColumn;
}
