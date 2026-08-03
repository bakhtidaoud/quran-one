import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/auth/domain/repositories/auth_repository.dart';

/// Google and Apple, in the order each platform expects.
///
/// Apple Sign In is not optional when Google is present: App Store Review
/// Guideline 4.8 makes its absence a rejection, not a preference. On
/// Android it is offered too, because an iPhone user with an Apple account
/// who switches to Android must still be able to reach their data.
class SocialButtons extends StatelessWidget {
  const SocialButtons({
    required this.onPressed,
    required this.busyProvider,
    super.key,
  });

  final ValueChanged<AuthProvider> onPressed;

  /// Which provider is mid-flight, if any. Only that button shows a
  /// spinner; the others disable without changing size.
  final AuthProvider? busyProvider;

  bool get _appleFirst => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      _SocialButton(
        provider: AuthProvider.apple,
        label: 'Continue with Apple',
        icon: Icons.apple,
        busy: busyProvider == AuthProvider.apple,
        enabled: busyProvider == null,
        onPressed: () => onPressed(AuthProvider.apple),
      ),
      _SocialButton(
        provider: AuthProvider.google,
        label: 'Continue with Google',
        icon: Icons.g_mobiledata,
        busy: busyProvider == AuthProvider.google,
        enabled: busyProvider == null,
        onPressed: () => onPressed(AuthProvider.google),
      ),
    ];

    return Column(
      children: (_appleFirst ? buttons : buttons.reversed.toList())
          .expand((b) => [b, const SizedBox(height: 12)])
          .toList()
        ..removeLast(),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.provider,
    required this.label,
    required this.icon,
    required this.busy,
    required this.enabled,
    required this.onPressed,
  });

  final AuthProvider provider;
  final String label;
  final IconData icon;
  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.outlineVariant),
          foregroundColor: colors.onSurface,
        ),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        // The label never changes to "Loading...". Swapping text mid-press
        // resizes the button and makes a deliberate tap feel like a
        // mis-tap.
        label: Text(label),
      ),
    );
  }
}
