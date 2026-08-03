import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';

/// The base settings row. Everything else in this module composes it.
///
/// Note what is absent: an `enabled` parameter. That is coding rule 16,
/// and the reason is that a disabled row is a dead end. It tells someone
/// they cannot do a thing without telling them why, or what would let
/// them. Either the row is actionable, or it is replaced by something
/// that explains itself.
class QSettingsTile extends StatelessWidget {
  const QSettingsTile({
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    super.key,
  });

  final String title;

  /// Beneath the title, muted. Use it for consequences, not decoration.
  final String? subtitle;

  /// The current setting, rendered at the end of the row.
  ///
  /// This is the single biggest usability win available in a settings
  /// list: it removes the need to open a page just to discover what is
  /// currently selected.
  final String? value;

  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isDestructive ? colors.error : colors.onSurface;

    return Semantics(
      button: onTap != null,
      // Title, value and subtitle are one label rather than three nodes.
      // A screen reader user should hear "Language, Arabic, button" in a
      // single utterance instead of tabbing around to discover state.
      label: [
        title,
        if (value != null) value!,
        if (subtitle != null) subtitle!,
      ].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          // 56, not the 48 WCAG floor. A settings list is scanned fast and
          // thumb-tapped, and the extra 8dp measurably reduces mis-taps.
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(color: foreground, size: 22),
                    child: leading!,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.bodyLarge
                            ?.copyWith(color: foreground),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: context.text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (value != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      end: 4,
                    ),
                    child: Text(
                      value!,
                      style: context.text.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  // Directional icon, so it flips in Arabic without a
                  // single Directionality check.
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A toggle row where the ENTIRE row is the target.
///
/// A 32dp switch at the far end of a 400dp row is a target most people
/// miss at least once, and on this screen every miss either changes a
/// setting or does nothing at all. Both feel broken.
class QSettingsSwitchTile extends StatelessWidget {
  const QSettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // `toggled`, not `button`. TalkBack then announces on/off and treats
      // double-tap as a toggle rather than an activation.
      toggled: value,
      label: [title, if (subtitle != null) subtitle!].join(', '),
      excludeSemantics: true,
      child: QSettingsTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        onTap: () => onChanged(!value),
        trailing: ExcludeSemantics(
          child: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}
