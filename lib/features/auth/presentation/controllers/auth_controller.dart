import 'package:flutter/foundation.dart';
import 'package:quran_one/features/auth/domain/entities/session.dart';
import 'package:quran_one/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);

    final subscription = repo.watch().listen((next) => state = next);
    ref.onDispose(subscription.cancel);

    // Restore runs after the first frame, deliberately.
    unawaited(repo.restore().then((restored) => state = restored));

    // A synchronous initial value, because the router's redirect runs on
    // the first frame. An async initial state guarantees a visible flash
    // of the wrong screen on every cold start.
    return const Guest();
  }

  Future<void> signOut({bool everywhere = false}) async {
    // Optimistic. Sign-out must never appear to fail: the local state is
    // what the user sees, and the server call is cleanup.
    state = const Guest(hasLocalData: true);
    await ref.read(authRepositoryProvider).signOut(everywhere: everywhere);
  }
}

/// Bridges Riverpod to GoRouter's refreshListenable.
///
/// Watches auth and nothing else. Every additional listenable makes the
/// redirect run on unrelated rebuilds, and a redirect firing during a
/// build is how you get an infinite loop that only reproduces on a slow
/// device in someone else's hands.
@Riverpod(keepAlive: true)
Listenable authListenable(Ref ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
}
