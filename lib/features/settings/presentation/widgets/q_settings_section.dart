import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';

/// A titled group of rows.
///
/// The header is a semantic heading so that screen reader users can jump
/// between sections. A forty-row settings tree navigated linearly is not
/// usable, and heading navigation is the whole remedy.
class QSettingsSection extends StatelessWidget {
  const QSettingsSection({
    required this.children,
    this.title,
    this.footnote,
    super.key,
  });

  final String? title;
  final List<Widget> children;

  /// Plain-language explanation below the group.
  ///
  /// This is where a setting earns trust. "Analytics is off unless you
  /// turn it on, and it never includes what you read" is worth more than
  /// a link to a policy nobody opens.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 20,
              end: 20,
              top: 24,
              bottom: 8,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title!,
                style: context.text.labelLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ...children,
        if (footnote != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 20,
              end: 20,
              top: 8,
            ),
            child: Text(
              footnote!,
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
