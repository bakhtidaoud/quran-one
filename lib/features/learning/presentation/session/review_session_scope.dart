import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one place the app uses a nested scope.
///
/// A memorisation review session has state that must not outlive the route:
/// the queue, the current card, how many were graded. Holding that in a
/// global provider means backing out mid-session and returning leaves the
/// user in a session they thought they had left.
///
/// Scoping is used here and nowhere else. Applied liberally it obscures more
/// than it isolates, because the answer to "where does this value come from"
/// stops being findable by reading one file.
class ReviewSessionScope extends StatelessWidget {
  const ReviewSessionScope({
    required this.sessionId,
    required this.child,
    super.key,
  });

  final String sessionId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        currentSessionIdProvider.overrideWithValue(sessionId),
      ],
      child: child,
    );
  }
}

/// Throws outside a [ReviewSessionScope], on purpose.
///
/// Returning null here would let a widget read a session id of null and
/// render an empty review screen. Failing loudly at the point of the mistake
/// is cheaper than debugging a blank page.
final currentSessionIdProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'currentSessionIdProvider is only available inside ReviewSessionScope',
  ),
);
