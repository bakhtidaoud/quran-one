import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/core/storage/preferences.dart';
import 'package:quran_one/core/theme/theme.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Quran One', style: context.text.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Read, pray and memorise. Everything works offline.',
                style: context.text.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(preferencesProvider)
                      .setOnboarded(value: true);
                  if (context.mounted) context.go(Routes.home);
                },
                child: const Text('Get started'),
              ),
              const SizedBox(height: 8),
              // Always visible, never buried. An account is never required
              // to worship.
              TextButton(
                onPressed: () async {
                  await ref
                      .read(preferencesProvider)
                      .setOnboarded(value: true);
                  if (context.mounted) context.go(Routes.home);
                },
                child: const Text('Continue without an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
