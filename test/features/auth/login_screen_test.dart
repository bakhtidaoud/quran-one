// Login screen widget tests.
//
// Three tests, not thirty. Nothing here asserts that TextFormField can
// show an error string, because that is the framework's job and it
// breaks on every version bump for no signal.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/features/auth/presentation/screens/login_screen.dart';

import '../../helpers/fakes/fake_auth_repository.dart';

void main() {
  testWidgets('a cancelled social sign in shows no error', (tester) async {
    // The most common defect in social auth: a red banner because the
    // user changed their mind at the system sheet. Cancellation is not
    // a failure, it is a decision.
    final repository = FakeAuthRepository()
      ..nextFailure = const CancelledFailure(message: 'cancelled');

    await tester.pumpWidget(_wrap(repository));
    await tester.tap(find.byKey(const Key('login.apple')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login.error')), findsNothing);
    expect(find.byKey(const Key('login.apple')), findsOneWidget);
  });

  testWidgets('a rejected credential announces once', (tester) async {
    final handle = tester.ensureSemantics();
    final repository = FakeAuthRepository()
      ..nextFailure = const UnauthorizedFailure(message: 'bad credentials');

    await tester.pumpWidget(_wrap(repository));
    await tester.enterText(
        find.byKey(const Key('login.email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('login.password')), 'wrong');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    final banner = find.byKey(const Key('login.error'));
    expect(banner, findsOneWidget);

    // The message must never distinguish an unknown address from a
    // wrong password. An account existence oracle in a religious app
    // is a way to enumerate who is Muslim.
    final text = tester.widget<Text>(
      find.descendant(of: banner, matching: find.byType(Text)),
    );
    expect(text.data, isNot(contains('exist')));
    expect(text.data, isNot(contains('found')));

    handle.dispose();
  });

  testWidgets('the submit button does not resize while loading',
      (tester) async {
    // A button that shrinks to fit a spinner moves everything below it
    // and steals the next tap.
    final repository = FakeAuthRepository()..holdPending = true;

    await tester.pumpWidget(_wrap(repository));
    final before = tester.getSize(find.byKey(const Key('login.submit')));

    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();

    expect(tester.getSize(find.byKey(const Key('login.submit'))), before);
  });

  testWidgets('an offline attempt does not clear local state',
      (tester) async {
    final repository = FakeAuthRepository()
      ..nextFailure = const NetworkFailure(message: 'offline');

    await tester.pumpWidget(_wrap(repository));
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 0);
    expect(repository.clearLocalCalls, 0);
  });
}

Widget _wrap(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: repository.overrides,
    child: const MaterialApp(home: LoginScreen()),
  );
}
