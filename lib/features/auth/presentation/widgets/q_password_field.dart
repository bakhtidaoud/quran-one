import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A password field whose visibility toggle is announced correctly.
///
/// The usual implementation is an IconButton with no label, which
/// TalkBack reads as "button" and VoiceOver reads as "eye". Neither tells
/// a blind user what will happen, and a password field is precisely where
/// guessing is expensive.
class QPasswordField extends StatefulWidget {
  const QPasswordField({
    required this.controller,
    required this.label,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.validator,
    this.autofillHints = const [AutofillHints.password],
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final Iterable<String> autofillHints;
  final String? errorText;

  @override
  State<QPasswordField> createState() => _QPasswordFieldState();
}

class _QPasswordFieldState extends State<QPasswordField> {
  bool _obscured = true;

  void _toggle() {
    setState(() => _obscured = !_obscured);
    // Haptic on toggle. The state change is otherwise invisible to anyone
    // not looking directly at the field.
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      // Never enableSuggestions or autocorrect on a password. Both leak
      // the value into the platform keyboard dictionary.
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        // Two lines of error room, reserved. A field that grows when it
        // fails shifts every control beneath it, and users tap the wrong
        // one.
        helperText: ' ',
        suffixIcon: Semantics(
          button: true,
          label: _obscured ? 'Show password' : 'Hide password',
          child: IconButton(
            onPressed: _toggle,
            // 48x48 minimum, enforced. The default IconButton in a suffix
            // slot can render at 40 and fails WCAG 2.2 target size.
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                key: ValueKey(_obscured),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
