import 'package:flutter/foundation.dart';

@immutable
class Account {
  const Account({
    required this.id,
    required this.email,
    this.displayName,
    this.emailVerified = false,
  });

  final String id;
  final String email;
  final String? displayName;

  /// Verification gates almost nothing: an unverified account can read,
  /// sync and subscribe. It cannot change its email or receive a password
  /// reset. Blocking the app's core function behind an email that landed
  /// in spam is a support burden with no security benefit.
  final bool emailVerified;
}

@immutable
class Session {
  const Session({
    required this.account,
    required this.accessExpiresAt,
  });

  final Account account;
  final DateTime accessExpiresAt;
}

/// Three states, exhaustively. Deliberately not `Account?`.
///
/// A nullable account cannot distinguish "never signed in" from "signed in
/// and the token just died", and those need opposite behaviour: the first
/// shows a sign-in offer, the second shows nothing at all and retries
/// quietly in the background.
sealed class AuthState {
  const AuthState();

  bool get isSignedIn => this is Authenticated;

  String? get accountId => switch (this) {
        Authenticated(:final session) => session.account.id,
        Expired(:final lastAccountId) => lastAccountId,
        Guest() => null,
      };
}

/// The default state, and a permanent one if the user wants it.
///
/// Guest is not degraded. Reading, prayer times, qibla, azkar and local
/// memorisation all work here, forever. Only profile, subscription
/// management and cross-device sync are behind the gate, which is why
/// nothing in this app ever has to block on authentication.
class Guest extends AuthState {
  const Guest({this.hasLocalData = false});

  /// True when this device holds bookmarks or hifz cards created before
  /// any sign-in. Drives the claim flow on first authentication.
  final bool hasLocalData;
}

class Authenticated extends AuthState {
  const Authenticated(this.session);
  final Session session;
}

/// Refresh failed. Distinct from Guest because local data still belongs to
/// a known account, so the app retries silently on next connectivity
/// rather than treating the device as a fresh anonymous install.
///
/// The user is never interrupted for this. The only visible change is that
/// the sync indicator stops.
class Expired extends AuthState {
  const Expired({required this.lastAccountId});
  final String lastAccountId;
}
