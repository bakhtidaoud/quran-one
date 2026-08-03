import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';

/// Routes that genuinely need a server-side identity.
///
/// Deliberately short. Everything absent from this set works signed out,
/// forever: reading, prayer times, qibla, azkar, local memorisation. A
/// guard that redirects an unauthenticated user away from the mushaf is a
/// bug, not a feature, so this is an allow-list of protected routes rather
/// than a gate on the app.
const protectedRoutes = <String>{
  Routes.profile,
  Routes.premiumManage,
  Routes.settingsSync,
};

class RouteGuards {
  const RouteGuards({
    required this.isOnboarded,
    required this.isAuthenticated,
  });

  final bool Function() isOnboarded;
  final bool Function() isAuthenticated;

  String? redirect(GoRouterState state) {
    final location = state.matchedLocation;

    // Onboarding is the only hard gate, and it is one-way. Once complete
    // the route stops resolving, so back-navigation cannot re-enter it.
    if (!isOnboarded()) {
      return location == Routes.onboarding ? null : Routes.onboarding;
    }
    if (location == Routes.onboarding) return Routes.home;

    if (protectedRoutes.contains(location) && !isAuthenticated()) {
      // Carry the destination. Dropping someone on home after a login they
      // only began because they tapped Profile is a small, constant
      // insult, and it is the reason people abandon sign-up flows.
      return Uri(
        path: Routes.login,
        queryParameters: {'from': location},
      ).toString();
    }

    if (location == Routes.login && isAuthenticated()) {
      return state.uri.queryParameters['from'] ?? Routes.home;
    }

    return null;
  }
}
