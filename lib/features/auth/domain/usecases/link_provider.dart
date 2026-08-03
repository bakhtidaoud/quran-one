import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/auth/domain/entities/session.dart';
import 'package:quran_one/features/auth/domain/repositories/auth_repository.dart';

/// Raised when the chosen provider identity already belongs to a
/// different Quran One account. Never resolved automatically.
class AccountLinkConflictFailure extends QFailure {
  const AccountLinkConflictFailure(String message)
      : super(message: message, traceId: null);
}

/// Links a second sign-in method to the account already signed in.
///
/// The rule that matters is enforced on the server, and it is worth
/// stating here because it is the difference between a feature and a
/// full account takeover:
///
/// An account is auto-linked by email address ONLY when the provider
/// asserts that the address is verified. Google does. Apple does for real
/// addresses. Neither does for an address a user simply typed.
///
/// Skipping the check works like this: an attacker registers with
/// password auth using victim@example.com and never verifies it. The
/// victim later signs in with Google on that same address, is silently
/// dropped into the attacker's account, and hands over everything.
class LinkProvider {
  const LinkProvider(this._repository);

  final AuthRepository _repository;

  Future<Result<Account, QFailure>> call(AuthProvider provider) async {
    final result = await _repository.linkProvider(provider);

    return result.fold(
      onOk: Ok.new,
      onErr: (failure) => switch (failure) {
        // 409 from the server. The resolution offered to the user must be
        // "sign in to that account instead", never "merge them" -- merge
        // is destructive and belongs behind deliberate navigation in
        // Settings, not inside an error dialog someone is trying to
        // dismiss.
        SyncConflictFailure() => const Err(
            AccountLinkConflictFailure(
              'That account is already linked to another Quran One profile.',
            ),
          ),
        _ => Err(failure),
      },
    );
  }
}
