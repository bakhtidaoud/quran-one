import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';

/// Shared chrome for login and register.
///
/// Responsive by content width rather than by device class. A 420dp column
/// centred on a tablet reads correctly; a form stretched across 1100dp of
/// desktop makes the eye travel the full width for a 12-character field.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;

  static const _maxContentWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // .sizeOf, not MediaQuery.of, so this rebuilds only on size change and
    // not on every keyboard inset or padding update.
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 700;

    return Scaffold(
      backgroundColor: colors.surface,
      // resizeToAvoidBottomInset with a scroll view, so the keyboard never
      // covers the field being typed into. This is the single most common
      // defect in sign-in screens.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 24,
              vertical: isCompact ? 16 : 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Semantic heading, so screen readers announce structure
                  // rather than reading a wall of text.
                  Semantics(
                    header: true,
                    child: Text(title, style: context.text.headlineMedium),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: isCompact ? 24 : 32),
                  ...children,
                  if (footer != null) ...[
                    const SizedBox(height: 24),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
