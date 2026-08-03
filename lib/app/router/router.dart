import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/core/storage/preferences.dart';
import 'package:quran_one/features/home/presentation/screens/home_screen.dart';
import 'package:quran_one/features/learning/presentation/screens/learn_screen.dart';
import 'package:quran_one/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:quran_one/features/prayer/presentation/screens/prayer_screen.dart';
import 'package:quran_one/features/quran/presentation/screens/quran_index_screen.dart';
import 'package:quran_one/features/quran/presentation/screens/reader_screen.dart';
import 'package:quran_one/features/settings/presentation/screens/settings_screen.dart';
import 'package:quran_one/shared/ui/scaffolds/root_shell.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _readKey = GlobalKey<NavigatorState>(debugLabel: 'read');
final _prayerKey = GlobalKey<NavigatorState>(debugLabel: 'prayer');
final _learnKey = GlobalKey<NavigatorState>(debugLabel: 'learn');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final onboarded = ref.watch(preferencesProvider).onboarded;

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboarded ? Routes.home : Routes.onboarding,
    restorationScopeId: 'q_router',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // The reader sits above the shell on purpose: full bleed, no nav bar.
      GoRoute(
        path: '/reader/:surahId',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => ReaderScreen(
          surahId: int.parse(state.pathParameters['surahId']!),
          initialAyah: int.tryParse(state.uri.queryParameters['ayah'] ?? ''),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => RootShell(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _readKey,
            routes: [
              GoRoute(
                path: Routes.read,
                builder: (_, __) => const QuranIndexScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _prayerKey,
            routes: [
              GoRoute(
                path: Routes.prayer,
                builder: (_, __) => const PrayerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _learnKey,
            routes: [
              GoRoute(
                path: Routes.learn,
                builder: (_, __) => const LearnScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
