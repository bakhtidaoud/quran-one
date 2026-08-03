import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_one/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:quran_one/features/auth/presentation/widgets/q_password_field.dart';
import 'package:quran_one/features/auth/presentation/widgets/social_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;
  AuthProvider? _socialBusy;
  QFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate on submit, not on every keystroke. Marking a field invalid
    // while someone is still typing their address is a scold, not help.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _failure = null;
    });

    final result = await ref.read(authRepositoryProvider).signInWithEmail(
          email: _email.text.trim(),
          password: _password.text,
        );

    if (!mounted) return;

    setState(() {
      _submitting = false;
      _failure = result.errorOrNull;
    });

    if (result.isOk) {
      // Return where they were headed, not to home. Dropping someone on
      // the home screen after a login they began by tapping Profile is a
      // small, constant insult.
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from ?? Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to sync your bookmarks and memorisation across '
          'devices.',
      footer: TextButton(
        onPressed: () => context.go(Routes.home),
        // The escape hatch is always visible and never buried. Guest is
        // the default state of this app, not a consolation prize, so
        // leaving must be as easy as staying.
        child: const Text('Continue without an account'),
      ),
      children: [
        // AutofillGroup, so the platform password manager offers to fill
        // and to save. Omitting it is why users invent weak passwords.
        AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText: ' ',
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Enter your email';
                    // Deliberately permissive. Strict email regexes reject
                    // valid addresses, and the server is the only place
                    // that can actually confirm one.
                    if (!v.contains('@') || v.length < 5) {
                      return 'That does not look like an email';
                    }
                    return null;
                  },
                ),
                QPasswordField(
                  controller: _password,
                  label: 'Password',
                  onSubmitted: (_) => _submit(),
                  validator: (value) =>
                      (value ?? '').isEmpty ? 'Enter your password' : null,
                ),
                if (_failure != null) _ErrorBanner(failure: _failure!),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign in'),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () => context.push(Routes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: colors.outlineVariant)),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: Text('or', style: context.text.labelMedium),
            ),
            Expanded(child: Divider(color: colors.outlineVariant)),
          ],
        ),
        const SizedBox(height: 16),
        SocialButtons(
          busyProvider: _socialBusy,
          onPressed: (provider) async {
            setState(() => _socialBusy = provider);
            await ref
                .read(authRepositoryProvider)
                .signInWithProvider(provider);
            if (mounted) setState(() => _socialBusy = null);
          },
        ),
      ],
    );
  }
}

/// Errors render inline, above the button, never as a SnackBar.
///
/// A SnackBar announcing a failed sign-in disappears after four seconds,
/// often before a screen reader has finished the sentence, and it covers
/// the button the user needs to press again.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.failure});

  final QFailure failure;

  String get _message => switch (failure) {
        UnauthorizedFailure() => 'Email or password is incorrect.',
        RateLimitedFailure(:final retryAfter) =>
          'Too many attempts. Try again in '
              '${retryAfter.inMinutes + 1} minutes.',
        NetworkFailure() || TimeoutFailure() =>
          'No connection. You can keep reading offline.',
        ValidationFailure(:final message) => message,
        _ => 'Something went wrong. Please try again.',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 8),
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 20, color: colors.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _message,
                style: context.text.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
